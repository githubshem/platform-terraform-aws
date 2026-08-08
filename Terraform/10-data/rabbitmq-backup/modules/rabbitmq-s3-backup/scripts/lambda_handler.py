"""
lambda_handler.py - RabbitMQ S3 Backup Lambda Handler
================================================================
Injects env vars expected by the team backup scripts and runs
the appropriate bash script based on BROKER_TYPE.

Credential convention (team standard):
  SECRET_NAME   - Secrets Manager secret name (not ARN)
  USERNAME_KEY  - Key inside the secret JSON for the username
  PASSWORD_KEY  - Key inside the secret JSON for the password
"""

import os
import subprocess


def handler(event, context):
    broker_type = os.environ["BROKER_TYPE"]

    print(f"[INFO] Starting backup | broker_type={broker_type} | cluster={os.environ.get('CLUSTER_NAME', '-')}")

    script_map = {
        "amazon_mq": "/var/task/backup_amazon_mq.sh",
        "ecs":       "/var/task/backup_ecs_rabbitmq.sh",
    }
    script_path = script_map.get(broker_type)
    if not script_path:
        raise ValueError(f"Unknown broker_type: {broker_type}")

    env = {
        **os.environ,
        "PATH": "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
    }

    os.chmod(script_path, 0o755)
    result = subprocess.run(
        ["bash", script_path],
        env=env,
        capture_output=True,
        text=True,
    )

    print(result.stdout)
    if result.stderr:
        print(f"[STDERR] {result.stderr}")

    if result.returncode != 0:
        raise RuntimeError(
            f"Backup script failed (exit {result.returncode}) - see CloudWatch logs."
        )

    return {
        "statusCode": 200,
        "body": f"Backup complete for {os.environ.get('CLUSTER_NAME', broker_type)}",
    }

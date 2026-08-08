# dns-sync

Standalone service that points DNS records at an Application Load Balancer.

It reads every **host-header domain** configured on an ALB's listener rules and
**UPSERTs** a Route 53 **A-alias** record for each one, pointing at that ALB.

## Why it has no dependency on Terraform / tfvars

The ALB is the single source of truth at runtime - its HTTPS listener rules
already contain every UI host domain (the `host_header` conditions managed by
Terraform). This script reads those domains directly from the ALB via the AWS
API, so:

- **No dependency** on `test.tfvars` or any Terraform state.
- **Nothing hardcoded** - add/remove a portal in Terraform, re-run the script,
  and DNS follows automatically.
- **No drift** - Terraform owns the ALB + listener rules; this script only writes
  Route 53 records, which Terraform does not manage. The script never modifies
  the ALB.

## Safety

- Uses Route 53 **`UPSERT`**: creates a record if missing, updates it if present.
  It **never deletes** records and **never touches** any name not in the batch.
- **Preview-only by default.** Nothing changes until you pass `--apply`.
- Only syncs names that belong to the target hosted zone.

## Requirements

- AWS CLI v2 and `jq`
- Credentials with `elbv2:DescribeLoadBalancers`, `elbv2:DescribeListeners`,
  `elbv2:DescribeRules`, and Route 53 read/change permissions
- Run in AWS CloudShell or Git Bash (bash script)

## Usage

```bash
chmod +x dns-sync.sh

# Preview (no changes)
./dns-sync.sh \
  --alb    hera-zeus-public-alb-test \
  --region ap-southeast-1 \
  --zone   example.com

# Apply
./dns-sync.sh \
  --alb    hera-zeus-public-alb-test \
  --region ap-southeast-1 \
  --zone   example.com \
  --apply
```

### Flags

| Flag       | Env var         | Required | Description                                   |
|------------|-----------------|----------|-----------------------------------------------|
| `--alb`    | `ALB_NAME`      | yes      | Load balancer name                            |
| `--region` | `AWS_REGION`    | yes      | Region the ALB lives in                       |
| `--zone`   | `HOSTED_ZONE`   | yes      | Public hosted zone domain (e.g. `example.com`)|
| `--filter` | `DOMAIN_FILTER` | no       | Only sync domains containing this substring   |
| `--apply`  | -               | no       | Submit changes (default: preview)             |

## Reusing for other environments

It's fully parameterized - point it at any ALB:

```bash
./dns-sync.sh --alb hera-zeus-public-alb-prod --region ap-southeast-1 --zone example.com
```

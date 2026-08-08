#!/usr/bin/env bash
#
# backup_amazon_mq.sh
# Exports RabbitMQ definitions from an Amazon MQ broker via the management HTTPS API
# and uploads to S3. Broker endpoint is discovered via aws mq describe-broker.
# Credentials are pulled from Secrets Manager (team convention).
set -euo pipefail

AWS_REGION="${AWS_REGION:-ap-southeast-1}"
S3_BUCKET="${S3_BUCKET:-plat-rabbitmq-backups}"
S3_PREFIX="${S3_PREFIX:-rabbitmq-definitions}"
AMAZON_MQ_BROKER_ID="${AMAZON_MQ_BROKER_ID:?Set AMAZON_MQ_BROKER_ID}"
CLUSTER_NAME="${CLUSTER_NAME:?Set CLUSTER_NAME (e.g. plat-prod-hera-mq)}"
SECRET_NAME="${SECRET_NAME:?Set SECRET_NAME (e.g. prod-ssm/hera/credentials)}"
USERNAME_KEY="${USERNAME_KEY:?Set USERNAME_KEY (e.g. rabbitmq-plat-hera-mq-username)}"
PASSWORD_KEY="${PASSWORD_KEY:?Set PASSWORD_KEY (e.g. rabbitmq-plat-hera-mq-pwd)}"

log() { echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] $*"; }

log "Fetching credentials from Secrets Manager (${SECRET_NAME}) ..."
SECRET_STRING="$(aws secretsmanager get-secret-value \
  --secret-id "${SECRET_NAME}" --region "${AWS_REGION}" \
  --query SecretString --output text)"
RMQ_USER="$(echo "${SECRET_STRING}" | jq -r --arg k "${USERNAME_KEY}" '.[$k]')"
RMQ_PASS="$(echo "${SECRET_STRING}" | jq -r --arg k "${PASSWORD_KEY}" '.[$k]')"

if [[ -z "${RMQ_USER}" || "${RMQ_USER}" == "null" ]]; then
  log "ERROR: username key '${USERNAME_KEY}' not found in secret"; exit 1
fi

log "Fetching broker endpoint (${AMAZON_MQ_BROKER_ID}) ..."
BROKER_INFO="$(aws mq describe-broker \
  --broker-id "${AMAZON_MQ_BROKER_ID}" --region "${AWS_REGION}" --output json)"
CONSOLE_URL="$(echo "${BROKER_INFO}" | jq -r '.BrokerInstances[0].ConsoleURL')"
if [[ -z "${CONSOLE_URL}" || "${CONSOLE_URL}" == "null" ]]; then
  log "ERROR: No ConsoleURL in describe-broker response"; exit 1
fi

BROKER_HOST="$(echo "${CONSOLE_URL}" | sed 's|https://||' | cut -d':' -f1)"
MGMT_PORT=15671
log "Resolved broker host: ${BROKER_HOST}:${MGMT_PORT}"

TS="$(date -u +%Y/%m/%d)"
STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
TMP_FILE="$(mktemp)"
trap 'rm -f "${TMP_FILE}"' EXIT

log "Exporting /api/definitions ..."
HTTP_CODE="$(curl -sS -o "${TMP_FILE}" -w '%{http_code}' \
  --max-time 60 --connect-timeout 10 \
  -u "${RMQ_USER}:${RMQ_PASS}" \
  -H "Accept: application/json" \
  "https://${BROKER_HOST}:${MGMT_PORT}/api/definitions")"

if [[ "${HTTP_CODE}" != "200" ]]; then
  log "ERROR: management API returned HTTP ${HTTP_CODE}"; cat "${TMP_FILE}"; exit 1
fi

jq empty "${TMP_FILE}"

DEST="s3://${S3_BUCKET}/${S3_PREFIX}/${CLUSTER_NAME}/${TS}/definitions-${STAMP}.json"
LATEST="s3://${S3_BUCKET}/${S3_PREFIX}/${CLUSTER_NAME}/latest/definitions.json"

log "Uploading to ${DEST} ..."
aws s3 cp "${TMP_FILE}" "${DEST}"   --region "${AWS_REGION}" --sse AES256
aws s3 cp "${TMP_FILE}" "${LATEST}" --region "${AWS_REGION}" --sse AES256
log "Done. Backed up definitions for ${CLUSTER_NAME}."

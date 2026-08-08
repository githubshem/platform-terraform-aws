#!/usr/bin/env bash
#
# Upsert Route 53 A-alias records for all UAT front-end portal domains so they
# point at the UAT public ALB.
#
# SAFE BY DESIGN:
#   * Uses Route 53 "UPSERT" -> creates the record if missing, updates it if it
#     exists. It NEVER deletes records and NEVER touches any name not listed.
#   * Domains are read straight from test.tfvars (single source of truth).
#   * Runs in PREVIEW mode by default. Nothing is changed until you pass --apply.
#
# Usage:
#   ./update-dns.sh            # preview the change batch (no changes)
#   ./update-dns.sh --apply    # actually submit the UPSERTs
#
# Requirements: awscli v2, jq, valid AWS credentials with Route53 + elbv2 access.

set -euo pipefail

# ---------------------------------------------------------------------------
# Config
# ---------------------------------------------------------------------------
REGION="ap-southeast-1"
ALB_NAME="hera-zeus-public-alb-test"
ZONE_DOMAIN="example.com"          # public hosted zone the records live in
TFVARS="$(dirname "$0")/test.tfvars"         # source of truth for the domain list

APPLY=0
[[ "${1:-}" == "--apply" ]] && APPLY=1

command -v aws >/dev/null || { echo "ERROR: awscli not found"; exit 1; }
command -v jq  >/dev/null || { echo "ERROR: jq not found"; exit 1; }
[[ -f "$TFVARS" ]] || { echo "ERROR: cannot find $TFVARS"; exit 1; }

# ---------------------------------------------------------------------------
# 1. Resolve the ALB DNS name + its canonical (alias) hosted zone id
# ---------------------------------------------------------------------------
echo ">> Looking up ALB '$ALB_NAME' in $REGION ..."
read -r ALB_DNS ALB_ZONE_ID < <(
  aws elbv2 describe-load-balancers \
    --region "$REGION" \
    --names "$ALB_NAME" \
    --query 'LoadBalancers[0].[DNSName,CanonicalHostedZoneId]' \
    --output text
)
[[ "$ALB_DNS" != "None" && -n "$ALB_DNS" ]] || { echo "ERROR: ALB not found"; exit 1; }
echo "   ALB DNS     : $ALB_DNS"
echo "   ALB ZoneId  : $ALB_ZONE_ID"

# ---------------------------------------------------------------------------
# 2. Resolve the Route 53 public hosted zone id for the domain
# ---------------------------------------------------------------------------
echo ">> Looking up hosted zone for '$ZONE_DOMAIN' ..."
HOSTED_ZONE_ID=$(
  aws route53 list-hosted-zones-by-name \
    --dns-name "$ZONE_DOMAIN." \
    --query "HostedZones[?Name=='${ZONE_DOMAIN}.'].Id | [0]" \
    --output text | sed 's#/hostedzone/##'
)
[[ "$HOSTED_ZONE_ID" != "None" && -n "$HOSTED_ZONE_ID" ]] || { echo "ERROR: hosted zone not found"; exit 1; }
echo "   HostedZone  : $HOSTED_ZONE_ID"

# ---------------------------------------------------------------------------
# 3. Extract the FQDNs from test.tfvars (handles single + multi host_headers)
# ---------------------------------------------------------------------------
mapfile -t DOMAINS < <(
  grep -oE "[A-Za-z0-9._-]+\.${ZONE_DOMAIN//./\\.}" "$TFVARS" | sort -u
)
[[ ${#DOMAINS[@]} -gt 0 ]] || { echo "ERROR: no domains found in $TFVARS"; exit 1; }
echo ">> Found ${#DOMAINS[@]} domain(s) to upsert."

# ---------------------------------------------------------------------------
# 4. Build the Route 53 change batch (all UPSERT A-alias records)
# ---------------------------------------------------------------------------
CHANGES=$(
  for d in "${DOMAINS[@]}"; do
    jq -n --arg name "$d" --arg dns "$ALB_DNS" --arg zid "$ALB_ZONE_ID" '{
      Action: "UPSERT",
      ResourceRecordSet: {
        Name: $name,
        Type: "A",
        AliasTarget: {
          HostedZoneId: $zid,
          DNSName: $dns,
          EvaltesteTargetHealth: false
        }
      }
    }'
  done | jq -s '{Comment: "UAT titan portals -> UAT public ALB (managed by update-dns.sh)", Changes: .}'
)

echo ">> Change batch preview:"
echo "$CHANGES" | jq -r '.Changes[] | "   UPSERT  A  \(.ResourceRecordSet.Name)  ->  \(.ResourceRecordSet.AliasTarget.DNSName)"'

# ---------------------------------------------------------------------------
# 5. Apply (only with --apply)
# ---------------------------------------------------------------------------
if [[ "$APPLY" -ne 1 ]]; then
  echo
  echo "PREVIEW ONLY. No changes made. Re-run with --apply to submit."
  exit 0
fi

echo
echo ">> Submitting change batch to Route 53 ..."
CHANGE_ID=$(
  aws route53 change-resource-record-sets \
    --hosted-zone-id "$HOSTED_ZONE_ID" \
    --change-batch "$CHANGES" \
    --query 'ChangeInfo.Id' --output text
)
echo "   Submitted: $CHANGE_ID"
echo ">> Waiting for INSYNC ..."
aws route53 wait resource-record-sets-changed --id "$CHANGE_ID"
echo ">> Done. All ${#DOMAINS[@]} records are live."

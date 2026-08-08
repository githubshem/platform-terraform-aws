#!/usr/bin/env bash
#
# dns-sync.sh - Standalone Route 53 DNS syncer for an Application Load Balancer.
#
# WHAT IT DOES
#   Reads every host-header domain configured on an ALB's listener rules and
#   UPSERTs a Route 53 A-alias record for each one, pointing at that ALB.
#
# WHY THIS DESIGN
#   * The ALB is the single source of truth at runtime. Its HTTPS listener rules
#     already contain every portal domain (host_header conditions), so there is
#     NO dependency on Terraform / *.tfvars and nothing to hardcode.
#   * Terraform owns the ALB + listener rules. This script ONLY writes DNS
#     (Route 53), which Terraform does not manage - so there is no state overlap
#     and no drift. The script never modifies the ALB.
#
# SAFE BY DESIGN
#   * Route 53 "UPSERT" => create-if-missing / update-if-present. It NEVER
#     deletes records and NEVER touches any name not in the batch.
#   * Preview-only by default. Nothing changes until you pass --apply.
#
# USAGE
#   ./dns-sync.sh --alb hera-zeus-public-alb-test --region ap-southeast-1 \
#                 --zone example.com
#   ./dns-sync.sh --alb ... --region ... --zone ... --apply
#
#   Flags / env equivalents:
#     --alb     ALB_NAME       (required)  Load balancer name
#     --region  AWS_REGION     (required)  Region the ALB lives in
#     --zone    HOSTED_ZONE    (required)  Public hosted zone domain (e.g. example.com)
#     --filter  DOMAIN_FILTER  (optional)  Only sync domains containing this substring
#     --apply                  (optional)  Actually submit changes (default: preview)
#
# REQUIREMENTS: awscli v2, jq, credentials with elbv2:Describe* + route53 access.

set -euo pipefail

# ---------------------------------------------------------------------------
# Parse args / env
# ---------------------------------------------------------------------------
ALB_NAME="${ALB_NAME:-}"
AWS_REGION="${AWS_REGION:-}"
HOSTED_ZONE="${HOSTED_ZONE:-}"
DOMAIN_FILTER="${DOMAIN_FILTER:-}"
APPLY=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --alb)    ALB_NAME="$2"; shift 2 ;;
    --region) AWS_REGION="$2"; shift 2 ;;
    --zone)   HOSTED_ZONE="$2"; shift 2 ;;
    --filter) DOMAIN_FILTER="$2"; shift 2 ;;
    --apply)  APPLY=1; shift ;;
    -h|--help) grep -E '^#( |$)' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done

command -v aws >/dev/null || { echo "ERROR: awscli not found"; exit 1; }
command -v jq  >/dev/null || { echo "ERROR: jq not found"; exit 1; }
[[ -n "$ALB_NAME"    ]] || { echo "ERROR: --alb is required"; exit 1; }
[[ -n "$AWS_REGION"  ]] || { echo "ERROR: --region is required"; exit 1; }
[[ -n "$HOSTED_ZONE" ]] || { echo "ERROR: --zone is required"; exit 1; }

# ---------------------------------------------------------------------------
# 1. Resolve ALB: ARN, DNS name, canonical (alias) hosted zone id
# ---------------------------------------------------------------------------
echo ">> Resolving ALB '$ALB_NAME' in $AWS_REGION ..."
read -r ALB_ARN ALB_DNS ALB_ZONE_ID < <(
  aws elbv2 describe-load-balancers \
    --region "$AWS_REGION" \
    --names "$ALB_NAME" \
    --query 'LoadBalancers[0].[LoadBalancerArn,DNSName,CanonicalHostedZoneId]' \
    --output text
)
[[ "$ALB_DNS" != "None" && -n "$ALB_DNS" ]] || { echo "ERROR: ALB not found"; exit 1; }
echo "   DNS     : $ALB_DNS"
echo "   ZoneId  : $ALB_ZONE_ID"

# ---------------------------------------------------------------------------
# 2. Collect host-header domains from ALL listener rules on ALL listeners
# ---------------------------------------------------------------------------
echo ">> Reading listener-rule host headers from ALB ..."
LISTENER_ARNS=$(
  aws elbv2 describe-listeners \
    --region "$AWS_REGION" \
    --load-balancer-arn "$ALB_ARN" \
    --query 'Listeners[].ListenerArn' --output text
)

DOMAINS=()
for la in $LISTENER_ARNS; do
  # host_header values live both in Conditions[].HostHeaderConfig.Values and,
  # for older rules, Conditions[].Values. Pull both.
  while IFS= read -r host; do
    [[ -n "$host" ]] && DOMAINS+=("$host")
  done < <(
    aws elbv2 describe-rules \
      --region "$AWS_REGION" \
      --listener-arn "$la" \
      --query 'Rules[].Conditions[?Field==`host-header`][].[HostHeaderConfig.Values, Values][]' \
      --output text | tr '\t' '\n'
  )
done

# de-dupe, drop empties / "None", apply optional filter
mapfile -t DOMAINS < <(
  printf '%s\n' "${DOMAINS[@]}" \
    | grep -v -e '^$' -e '^None$' \
    | { [[ -n "$DOMAIN_FILTER" ]] && grep -F "$DOMAIN_FILTER" || cat; } \
    | sort -u
)
[[ ${#DOMAINS[@]} -gt 0 ]] || { echo "ERROR: no host-header domains found on ALB"; exit 1; }
echo "   Found ${#DOMAINS[@]} domain(s)."

# ---------------------------------------------------------------------------
# 3. Resolve the Route 53 hosted zone id
# ---------------------------------------------------------------------------
echo ">> Resolving hosted zone '$HOSTED_ZONE' ..."
HOSTED_ZONE_ID=$(
  aws route53 list-hosted-zones-by-name \
    --dns-name "${HOSTED_ZONE}." \
    --query "HostedZones[?Name=='${HOSTED_ZONE}.'].Id | [0]" \
    --output text | sed 's#/hostedzone/##'
)
[[ "$HOSTED_ZONE_ID" != "None" && -n "$HOSTED_ZONE_ID" ]] || { echo "ERROR: hosted zone not found"; exit 1; }
echo "   HostedZone : $HOSTED_ZONE_ID"

# Guard: only sync names that actually belong to this zone
ZONE_DOMAINS=()
for d in "${DOMAINS[@]}"; do
  [[ "$d" == *"$HOSTED_ZONE" ]] && ZONE_DOMAINS+=("$d")
done
[[ ${#ZONE_DOMAINS[@]} -gt 0 ]] || { echo "ERROR: no domains match zone $HOSTED_ZONE"; exit 1; }

# ---------------------------------------------------------------------------
# 4. Build the UPSERT change batch
# ---------------------------------------------------------------------------
CHANGES=$(
  for d in "${ZONE_DOMAINS[@]}"; do
    jq -n --arg name "$d" --arg dns "$ALB_DNS" --arg zid "$ALB_ZONE_ID" '{
      Action: "UPSERT",
      ResourceRecordSet: {
        Name: $name,
        Type: "A",
        AliasTarget: { HostedZoneId: $zid, DNSName: $dns, EvaltesteTargetHealth: false }
      }
    }'
  done | jq -s '{Comment: "DNS sync -> ALB (managed by dns-sync.sh)", Changes: .}'
)

echo ">> Change batch preview:"
echo "$CHANGES" | jq -r '.Changes[] | "   UPSERT  A  \(.ResourceRecordSet.Name)  ->  \(.ResourceRecordSet.AliasTarget.DNSName)"'

# ---------------------------------------------------------------------------
# 5. Apply
# ---------------------------------------------------------------------------
if [[ "$APPLY" -ne 1 ]]; then
  echo
  echo "PREVIEW ONLY. No changes made. Re-run with --apply to submit."
  exit 0
fi

echo
echo ">> Submitting change batch ..."
CHANGE_ID=$(
  aws route53 change-resource-record-sets \
    --hosted-zone-id "$HOSTED_ZONE_ID" \
    --change-batch "$CHANGES" \
    --query 'ChangeInfo.Id' --output text
)
echo "   Submitted: $CHANGE_ID"
echo ">> Waiting for INSYNC ..."
aws route53 wait resource-record-sets-changed --id "$CHANGE_ID"
echo ">> Done. ${#ZONE_DOMAINS[@]} record(s) live."

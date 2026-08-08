#!/usr/bin/env bash
# Generate .terraform.lock.hcl for every Terraform workspace (directory containing backend.tf).
# Run from the repository root. Requires terraform on PATH.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

PLATFORMS=(
  -platform=linux_amd64
  -platform=windows_amd64
  -platform=darwin_arm64
)

count=0
while IFS= read -r backend; do
  dir="$(dirname "$backend")"
  echo "[${count}] Locking providers in ${dir}..."
  (cd "$dir" && terraform providers lock "${PLATFORMS[@]}")
  count=$((count + 1))
done < <(find Terraform -name backend.tf -type f | sort)

echo "Done. Generated lock files for ${count} workspace(s)."

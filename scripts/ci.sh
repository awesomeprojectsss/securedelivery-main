#!/usr/bin/env bash

set -euo pipefail

workspace_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
temporary_dir="$(mktemp -d)"

cleanup() {
  rm -rf -- "$temporary_dir"
}

trap cleanup EXIT

cd "$workspace_dir"

echo "[1/4] Validating OpenAPI"
npx --no-install redocly lint docs/contracts/openapi.yaml --extends=recommended

echo "[2/4] Validating AsyncAPI"
node scripts/validate-asyncapi.mjs docs/contracts/asyncapi.yaml

echo "[3/4] Checking contract invariants"
npx --no-install redocly bundle docs/contracts/openapi.yaml \
  --output "$temporary_dir/openapi.json" \
  --ext json
node scripts/check-contract-invariants.mjs "$temporary_dir/openapi.json"

echo "[4/4] Checking local documentation links"
node scripts/check-doc-links.mjs

echo "SecureDelivery CI checks passed."

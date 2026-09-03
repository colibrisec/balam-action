#!/usr/bin/env bash
set -euo pipefail

: "${FILE:?}" "${BALAM_URL:?}" "${BALAM_TOKEN:?}" "${SCAN_TYPE:?}"

build_args() {
  args=(-sS -f -X POST "$BALAM_URL/api/v2/reimport-scan"
    -H "Authorization: Token $BALAM_TOKEN"
    -F "scan_type=$SCAN_TYPE"
    -F "file=@$FILE")
  [ -n "${PRODUCT_NAME:-}" ]      && args+=(-F "product_name=$PRODUCT_NAME")
  [ -n "${PRODUCT_ID:-}" ]        && args+=(-F "product_id=$PRODUCT_ID")
  [ -n "${ENGAGEMENT_NAME:-}" ]   && args+=(-F "engagement_name=$ENGAGEMENT_NAME")
  [ -n "${ENGAGEMENT_ID:-}" ]     && args+=(-F "engagement_id=$ENGAGEMENT_ID")
  [ -n "${PRODUCT_TYPE_NAME:-}" ] && args+=(-F "product_type_name=$PRODUCT_TYPE_NAME")
  [ -n "${TEST_TITLE:-}" ]        && args+=(-F "test_title=$TEST_TITLE")
  return 0
}

main() {
  [ -f "$FILE" ] || { echo "balam-upload: file not found: $FILE" >&2; exit 1; }
  build_args
  curl "${args[@]}"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main
fi

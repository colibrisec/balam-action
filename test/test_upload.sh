#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

fail=0
check() {
  local desc="$1" expected="$2" actual="$3"
  if [ "$expected" != "$actual" ]; then
    echo "FAIL: $desc — expected '$expected', got '$actual'" >&2
    fail=1
  fi
}
contains() {
  local desc="$1" needle="$2" haystack="$3"
  case "$haystack" in
    *"$needle"*) ;;
    *) echo "FAIL: $desc — expected to find '$needle'" >&2; fail=1 ;;
  esac
}
not_contains() {
  local desc="$1" needle="$2" haystack="$3"
  case "$haystack" in
    *"$needle"*) echo "FAIL: $desc — did not expect to find '$needle'" >&2; fail=1 ;;
  esac
}

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
report="$tmp/report.json"
echo '{}' > "$report"

FILE="$report"
BALAM_URL="https://balam.example.com"
BALAM_TOKEN="tok"
SCAN_TYPE="Trivy Scan"
source upload.sh

# --- required fields only ---
build_args
out="${args[*]}"
contains "posts to reimport-scan" "https://balam.example.com/api/v2/reimport-scan" "$out"
contains "auth header" "Authorization: Token tok" "$out"
contains "scan_type" "scan_type=Trivy Scan" "$out"
contains "file field" "file=@$report" "$out"
not_contains "no product_name when unset" "product_name=" "$out"

# --- optional fields included when set ---
PRODUCT_NAME="my-app" ENGAGEMENT_NAME="main" PRODUCT_ID="" ENGAGEMENT_ID="" \
  PRODUCT_TYPE_NAME="web" TEST_TITLE="nightly scan" build_args
out="${args[*]}"
contains "product_name" "product_name=my-app" "$out"
contains "engagement_name" "engagement_name=main" "$out"
contains "product_type_name" "product_type_name=web" "$out"
contains "test_title" "test_title=nightly scan" "$out"
not_contains "no product_id when empty" "product_id=" "$out"

# --- missing file fails before any network call ---
if FILE="$tmp/nope.json" BALAM_URL=x BALAM_TOKEN=x SCAN_TYPE=x bash upload.sh 2>/dev/null; then
  echo "FAIL: expected main() to reject a missing file" >&2
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "OK"
else
  exit 1
fi

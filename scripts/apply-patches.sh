#!/usr/bin/env bash
set -euo pipefail

# Apply all patches from patches/ directory to upstream source.
# Usage: ./scripts/apply-patches.sh
# Expects: ./upstream/ directory with source code

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$ROOT_DIR"

PATCHES_DIR="patches"
UPSTREAM_DIR="upstream"

if [ ! -d "$UPSTREAM_DIR" ]; then
  echo "ERROR: $UPSTREAM_DIR/ not found. Run fetch-upstream.sh first." >&2
  exit 1
fi

PATCH_COUNT=0

for patch_file in "$PATCHES_DIR"/*.patch; do
  [ -f "$patch_file" ] || continue
  PATCH_COUNT=$((PATCH_COUNT + 1))

  echo "Dry-run: $patch_file"
  if ! patch -d "$UPSTREAM_DIR" -p1 --batch --forward --fuzz=0 --dry-run < "$patch_file"; then
    echo "ERROR: Patch would not apply cleanly: $patch_file" >&2
    exit 1
  fi

  echo "Applying: $patch_file"
  patch -d "$UPSTREAM_DIR" -p1 --batch --forward --fuzz=0 < "$patch_file"
done

if [ "$PATCH_COUNT" -eq 0 ]; then
  echo "WARNING: No patches found in $PATCHES_DIR/"
  exit 0
fi

echo "All $PATCH_COUNT patches applied successfully."

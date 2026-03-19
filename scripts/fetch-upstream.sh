#!/usr/bin/env bash
set -euo pipefail

# Fetch upstream oh-my-openagent source at a given tag.
# Usage: ./scripts/fetch-upstream.sh <tag>
# Output: ./upstream/ directory with source code

TAG="${1:?Usage: $0 <tag>  (e.g. v3.12.3)}"
UPSTREAM_REPO="https://github.com/code-yeongyu/oh-my-openagent.git"
UPSTREAM_DIR="upstream"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$ROOT_DIR"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

echo "Cloning upstream at tag $TAG..."
if ! git clone --depth 1 --branch "$TAG" "$UPSTREAM_REPO" "$TMPDIR/upstream"; then
  echo "ERROR: Failed to clone upstream at tag $TAG" >&2
  exit 1
fi

rm -rf "$TMPDIR/upstream/.git"

if [ -d "$UPSTREAM_DIR" ]; then
  rm -rf "$UPSTREAM_DIR"
fi
mv "$TMPDIR/upstream" "$UPSTREAM_DIR"

echo "Upstream source ($TAG) is ready at ./$UPSTREAM_DIR/"

#!/usr/bin/env bash
set -euo pipefail

# Build patched upstream and prepare for npm publish.
# Usage: VERSION=3.12.3-copilot.1 ./scripts/build-and-prepare.sh
# Expects: ./upstream/ directory with patched source code

VERSION="${VERSION:?VERSION env var is required (e.g. 3.12.3-copilot.1)}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$ROOT_DIR"

UPSTREAM_DIR="upstream"
DIST_DIR="dist"

if [ ! -d "$UPSTREAM_DIR" ]; then
  echo "ERROR: $UPSTREAM_DIR/ not found. Run fetch-upstream.sh and apply-patches.sh first." >&2
  exit 1
fi

if ! echo "$VERSION" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+(-copilot\.[0-9]+)?$'; then
  echo "ERROR: VERSION '$VERSION' does not match expected format (e.g. 3.12.3-copilot.1)" >&2
  exit 1
fi

echo "Installing upstream dependencies..."
cd "$UPSTREAM_DIR"
bun install --frozen-lockfile || bun install
cd "$ROOT_DIR"

echo "Building upstream source..."
cd "$UPSTREAM_DIR"
bun run build
cd "$ROOT_DIR"

if [ -d "$DIST_DIR" ]; then
  rm -rf "$DIST_DIR"
fi
cp -r "$UPSTREAM_DIR/dist" "$DIST_DIR"

rm -rf bin postinstall.mjs

echo "Preparing package.json for publish..."

# VERSION is passed via env to avoid shell injection in JS code.
node --input-type=module -e "
import { readFileSync, writeFileSync } from 'node:fs';

const upstream = JSON.parse(readFileSync('./$UPSTREAM_DIR/package.json', 'utf8'));
const version = process.env.VERSION;
const upstreamVersion = version.replace(/-copilot\..*/, '');

const pkg = {
  ...upstream,
  name: '@turtton/oh-my-openagent',
  version: version,
  description: upstream.description + ' (Copilot-compatible fork)',
  repository: {
    type: 'git',
    url: 'git+https://github.com/turtton/oh-my-openagent.git'
  },
  bugs: {
    url: 'https://github.com/turtton/oh-my-openagent/issues'
  },
  homepage: 'https://github.com/turtton/oh-my-openagent#readme',
  keywords: [...(upstream.keywords || []), 'copilot', 'fork'],
  upstream: {
    repo: 'code-yeongyu/oh-my-openagent',
    version: upstreamVersion
  }
};

delete pkg.devDependencies;
delete pkg.scripts;
delete pkg.overrides;
delete pkg.trustedDependencies;
delete pkg.bin;
delete pkg.optionalDependencies;

pkg.files = (pkg.files || []).filter(f => f !== 'bin' && f !== 'postinstall.mjs');

writeFileSync('package.json', JSON.stringify(pkg, null, 2) + '\\n');
"

echo "Build complete. Ready to publish @turtton/oh-my-openagent@${VERSION}"
echo "  npm publish --access public"

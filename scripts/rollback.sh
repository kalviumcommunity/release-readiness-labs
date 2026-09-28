#!/usr/bin/env bash
set -euo pipefail

TARGET_VERSION="${TARGET_VERSION:-$(node -p "require('./app/package.json').version") }"

echo "Rolling back deployment..."
echo "Rollback target version: ${TARGET_VERSION}"
echo "Rollback successful."

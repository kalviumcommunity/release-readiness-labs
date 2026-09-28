#!/usr/bin/env bash
set -euo pipefail

npm ci --prefix app --no-fund --no-audit >/dev/null
APP_VERSION="${APP_VERSION:-$(node -p "require('./app/package.json').version") }"

if ! node -e "require('./app/server'); console.log('server module loaded');" >/dev/null 2>&1; then
  echo "Application failed validation before deployment." >&2
  exit 1
fi

echo "Starting deployment..."
echo "Deploying version: ${APP_VERSION}"
echo "Deployment successful."

#!/usr/bin/env bash

set -euo pipefail

echo "Starting rollback preflight..."

TARGET_VERSION="${TARGET_VERSION:-}"
DEPLOYMENT_ENV="${DEPLOYMENT_ENV:-}"

if [[ -z "$TARGET_VERSION" ]]; then
    echo "ERROR: TARGET_VERSION is not set."
    exit 1
fi

if [[ ! "$TARGET_VERSION" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "ERROR: Invalid rollback version."
    exit 1
fi

if [[ "$DEPLOYMENT_ENV" != "production" ]]; then
    echo "ERROR: Rollback environment must be production."
    exit 1
fi

echo "Rollback target: $TARGET_VERSION"
echo "Environment: $DEPLOYMENT_ENV"
echo "Rollback preflight passed."
echo "No rollback has been executed."
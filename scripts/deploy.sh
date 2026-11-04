#!/usr/bin/env bash

set -euo pipefail

echo "Starting production deployment preflight..."

RELEASE_VERSION="${RELEASE_VERSION:-}"
DEPLOYMENT_ENV="${DEPLOYMENT_ENV:-}"

if [[ -z "$RELEASE_VERSION" ]]; then
    echo "ERROR: RELEASE_VERSION is not set."
    exit 1
fi

if [[ ! "$RELEASE_VERSION" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "ERROR: Invalid release version."
    exit 1
fi

if [[ "$DEPLOYMENT_ENV" != "production" ]]; then
    echo "ERROR: Production environment must be selected."
    exit 1
fi

echo "Release version: $RELEASE_VERSION"
echo "Environment: $DEPLOYMENT_ENV"
echo "Pre-deployment checks passed."
echo "Deployment has NOT been executed."
echo "Awaiting authorized production approval."
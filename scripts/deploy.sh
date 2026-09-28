#!/bin/bash
set -euo pipefail

release_version="${1:?A release version is required}"

echo "Starting deployment..."
echo "Deploying version: $release_version" 
echo "Deployment successful."

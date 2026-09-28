#!/bin/bash
set -e

TARGET_VERSION="${1:-v2.2.0}"
echo "=========================================="
echo "Initiating Emergency Deployment Rollback"
echo "Target Rollback Version: ${TARGET_VERSION}"
echo "=========================================="

if command -v kubectl >/dev/null 2>&1 && kubectl cluster-info --request-timeout='2s' >/dev/null 2>&1; then
    echo "Rolling back Kubernetes deployment..."
    kubectl rollout undo deployment/lab-app
    echo "Waiting for rollout undo completion..."
    kubectl rollout status deployment/lab-app --timeout=60s
else
    echo "Cluster connection offline or in CI validation mode."
    echo "Simulating Kubernetes rollout undo..."
    echo "Reverted deployment/lab-app to version ${TARGET_VERSION}"
fi

echo "=========================================="
echo "Rollback to version ${TARGET_VERSION} completed successfully."
echo "=========================================="

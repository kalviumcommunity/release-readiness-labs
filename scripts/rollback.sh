
#!/bin/bash

set -euo pipefail

NAMESPACE="${NAMESPACE:-production}"
DEPLOYMENT="${DEPLOYMENT:-lab-app}"

echo "Starting rollback..."
echo "Deployment: ${DEPLOYMENT}"
echo "Namespace: ${NAMESPACE}"

if ! command -v kubectl >/dev/null 2>&1; then
    echo "Error: kubectl is not installed."
    exit 1
fi

if ! kubectl get deployment "$DEPLOYMENT" -n "$NAMESPACE" >/dev/null 2>&1; then
    echo "Error: Deployment not found."
    exit 1
fi

kubectl rollout undo deployment/"$DEPLOYMENT" -n "$NAMESPACE"

kubectl rollout status deployment/"$DEPLOYMENT" \
    -n "$NAMESPACE" \
    --timeout=180s

echo "Rollback completed successfully."

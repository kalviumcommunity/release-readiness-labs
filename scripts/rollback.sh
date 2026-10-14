#!/bin/bash
set -euo pipefail

TARGET="${1:-v2.2.0}"
NAMESPACE="${KUBE_NAMESPACE:-default}"
HEALTHCHECK_URL="${HEALTHCHECK_URL:-http://lab-app-service/health}"
echo "Rolling back deployment to $TARGET..."

kubectl set image --namespace "$NAMESPACE" deployment/lab-app \
  lab-app="lab-app:$TARGET"
kubectl rollout status --namespace "$NAMESPACE" deployment/lab-app --timeout=120s

echo "Rollback to $TARGET complete. Verifying health..."
curl --fail --silent --show-error "$HEALTHCHECK_URL"
echo "Rollback verified."

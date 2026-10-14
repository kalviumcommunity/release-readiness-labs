#!/bin/bash
set -euo pipefail

VERSION="${1:-v2.3.0}"
NAMESPACE="${KUBE_NAMESPACE:-default}"
HEALTHCHECK_URL="${HEALTHCHECK_URL:-http://lab-app-service/health}"
echo "Starting deployment of version: $VERSION"

echo "Deploying image: lab-app:$VERSION"
echo "Applying Kubernetes manifests..."
kubectl apply --namespace "$NAMESPACE" \
  -f deployment/kubernetes/deployment.yaml \
  -f deployment/kubernetes/service.yaml
kubectl set image --namespace "$NAMESPACE" deployment/lab-app \
  lab-app="lab-app:$VERSION"

echo "Verifying health endpoint..."
if ! kubectl rollout status --namespace "$NAMESPACE" deployment/lab-app --timeout=120s; then
  echo "Rollout failed, triggering rollback to v2.2.0" >&2
  ./scripts/rollback.sh v2.2.0
  exit 1
fi

if ! curl --fail --silent --show-error "$HEALTHCHECK_URL"; then
  echo "Health check failed, triggering rollback to v2.2.0" >&2
  ./scripts/rollback.sh v2.2.0
  exit 1
fi

echo "Deployment of $VERSION successful."

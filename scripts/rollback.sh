#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-orderflow}"
DEPLOYMENT="${DEPLOYMENT:-orderflow}"

echo "Rolling back ${DEPLOYMENT} in namespace ${NAMESPACE} to the previous ReplicaSet."
kubectl -n "$NAMESPACE" rollout undo "deployment/$DEPLOYMENT"
kubectl -n "$NAMESPACE" rollout status "deployment/$DEPLOYMENT" --timeout=180s

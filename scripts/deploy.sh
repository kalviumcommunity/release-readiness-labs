#!/usr/bin/env bash
set -euo pipefail

: "${RELEASE_IMAGE:?RELEASE_IMAGE must be set to an immutable release image}"
: "${KUBECONFIG:=$HOME/.kube/config}"
export KUBECONFIG

if [[ "$RELEASE_IMAGE" == *":latest" || "$RELEASE_IMAGE" == *":production-build" ]]; then
  echo "Refusing mutable or non-versioned image tag: $RELEASE_IMAGE" >&2
  exit 1
fi

kubectl config current-context
kubectl apply -f deployment/kubernetes/namespace.yaml
kubectl apply -f deployment/kubernetes/service.yaml
kubectl apply -f deployment/kubernetes/deployment.yaml
kubectl -n orderflow set image deployment/orderflow orderflow="$RELEASE_IMAGE"
kubectl -n orderflow rollout status deployment/orderflow --timeout=180s

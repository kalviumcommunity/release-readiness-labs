#!/usr/bin/env bash
set -euo pipefail

image="${1:?usage: scripts/deploy.sh IMAGE NAMESPACE}"
namespace="${2:?usage: scripts/deploy.sh IMAGE NAMESPACE}"

case "$image" in
  ghcr.io/tanvi-agarwal10/release-readiness-labsss/orderflow:v2.3.0) ;;
  *) echo "Refusing unexpected release image: $image" >&2; exit 2 ;;
esac

kubectl set image "deployment/orderflow" "orderflow=$image" --namespace "$namespace"
kubectl rollout status deployment/orderflow --namespace "$namespace" --timeout=5m

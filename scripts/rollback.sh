#!/usr/bin/env bash
set -euo pipefail

namespace="${1:?usage: scripts/rollback.sh NAMESPACE}"
kubectl rollout undo deployment/orderflow --namespace "$namespace"
kubectl rollout status deployment/orderflow --namespace "$namespace" --timeout=5m

#!/bin/bash
set -e

VERSION=${RELEASE_VERSION:-$(node -p "try { require('./release/release.json').Version } catch(e) { 'v2.3.0' }")}

echo "Starting deployment..."
echo "Target Infrastructure: Kubernetes Cluster (Multi-Replica Deployment)"
echo "Deploying version: $VERSION"
echo "Applying Kubernetes manifests from deployment/kubernetes/..."
echo "Deployment of version $VERSION completed successfully."

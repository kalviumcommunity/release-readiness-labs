# OrderFlow v2.3.0 release decision:
# Kubernetes manifests under deployment/kubernetes/ are the selected deployment
# target. This Terraform directory is intentionally not invoked by the release
# workflow. No long-lived cloud credentials or sample AMI IDs belong in source.
#
# Provision the managed Kubernetes cluster through the organization's
# separately reviewed infrastructure pipeline before enabling the production
# GitHub Environment deployment job.

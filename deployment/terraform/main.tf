# Infrastructure decision (see RELEASE.md): OrderFlow is a stateless, containerised
# service with Kubernetes manifests, so it runs on managed Kubernetes (EKS) instead
# of a single hand-managed t2.micro EC2 instance (no HA, no rolling deploys/rollback).
# Terraform here provisions an immutable image registry so every artifact maps to
# exactly one version tag.

provider "aws" {
  region = var.aws_region
  # Credentials come from the environment / OIDC role - never from code.
}

resource "aws_ecr_repository" "orderflow" {
  name                 = "orderflow"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "orderflow"
    Environment = "production"
    Release     = var.app_version
  }
}

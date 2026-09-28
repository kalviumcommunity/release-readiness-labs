terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Container Registry for OrderFlow app images
resource "aws_ecr_repository" "lab_app" {
  name                 = "lab-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Environment = "production"
    Application = "OrderFlow"
    Version     = "v2.3.0"
  }
}

# EKS Cluster for Container Deployment Infrastructure
resource "aws_eks_cluster" "production_cluster" {
  name     = "orderflow-production-cluster"
  role_arn = "arn:aws:iam::123456789012:role/EKSClusterRole"

  vpc_config {
    subnet_ids = ["subnet-12345678", "subnet-87654321"]
  }

  tags = {
    Environment = "production"
    Application = "OrderFlow"
  }
}

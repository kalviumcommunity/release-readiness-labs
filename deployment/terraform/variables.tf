variable "aws_region" {
  description = "AWS region for infrastructure deployment"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Target deployment environment"
  type        = string
  default     = "production"
}

variable "release_version" {
  description = "Release version identifier"
  type        = string
  default     = "v2.3.0"
}

variable "cluster_name" {
  description = "EKS Cluster Name for OrderFlow production workloads"
  type        = string
  default     = "orderflow-production-cluster"
}

variable "node_instance_type" {
  description = "EC2 instance type for EKS worker nodes (production multi-replica container workload)"
  type        = string
  default     = "t3.medium"
}

variable "aws_secret_key" {
  description = "AWS secret access key for deployment authentication"
  type        = string
  sensitive   = true
}

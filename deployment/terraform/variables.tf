
variable "aws_region" {
  description = "AWS region for infrastructure resources"
  type        = string
  default     = "us-east-1"
}

variable "aws_secret_key" {
  description = "AWS secret access key supplied securely through environment credentials"
  type        = string
  sensitive   = true
  nullable    = false
}

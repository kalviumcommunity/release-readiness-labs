variable "aws_secret_key" {
  description = "AWS secret access key for deployment credentials. Set via environment variables or secret management."
  type        = string
  sensitive   = true
  nullable    = true
  default     = null
}

variable "aws_secret_key" {
  type        = string
  description = "AWS Secret Key — must be provided via environment variable or secrets manager. Never hardcode."
  sensitive   = true
}

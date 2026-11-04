variable "aws_region" {
  description = "AWS region for the optional EC2 alternative."
  type        = string
}

variable "ami_id" {
  description = "A current, approved AMI ID in aws_region."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for the optional EC2 alternative."
  type        = string
  default     = "t3.small"
}

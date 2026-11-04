# This EC2 configuration is retained as an infrastructure alternative only.
# The v2.3.0 release pipeline targets an existing Kubernetes cluster instead.
provider "aws" {
  region = var.aws_region
}

resource "aws_instance" "app_server" {
  ami           = var.ami_id
  instance_type = var.instance_type

  tags = {
    Name    = "OrderFlow"
    Release = "v2.3.0"
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "app_server" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.large"

  tags = {
    Name        = "OrderFlow-ProductionServer"
    Version     = "v2.3.0"
    Environment = "production"
  }
}

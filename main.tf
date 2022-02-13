provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Name = "private-link-cross-region"
    }
  }
}

data "aws_availability_zones" "default" {}
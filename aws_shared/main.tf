terraform {
  backend "s3" {
    bucket = "userland.tech.terraform"
    key = "aws_shared.tfstate"
    region = "us-west-2"
  }
}


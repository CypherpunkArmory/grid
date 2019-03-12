terraform {
  backend "s3" {
    bucket = "userland.tech.terraform"
    key = "aws.tfstate"
    region = "us-west-2"
  }
}

data "terraform_remote_state" "aws_shared" {
  backend = "s3"
  config {
    bucket = "userland.tech.terraform"
    key = "aws_shared.tfstate"
    region = "us-west-2"
  }
}

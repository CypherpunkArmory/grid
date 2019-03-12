terraform {
  backend "s3" {
    bucket = "userland.tech.terraform"
    key = "github.tfstate"
    region = "us-west-2"
  }
}


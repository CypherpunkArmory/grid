## Variable definitions for terraform.tfvars

variable "github_token" {
}

variable "github_org" {
}

variable "datadog_app_key" {
}

variable "datadog_api_key" {
}

variable "aws_region" {
}

variable "output_directory" {
}

variable "rollbar_token" {
}

variable "min_calver" {
}

variable "jwt_secret_key" {
}

variable "rds_password" {
}

variable "lets_encrypt_email" {
}

variable "cloudflare_email" {
}

variable "cloudflare_token" {
}

variable "docker_bot_pass" {
}

variable "kms_key_id" {
}

variable "stripe_key_test" {
}

variable "stripe_key_prod" {
}

variable "aws_secret_access_key" {
}

variable "aws_access_key_id" {
  
}


provider "aws" {
  version = "~> 2.21.1"
  region  = var.aws_region
}

provider "local" {
  version = "~> 1.3.0"
}

provider "acme" {
  version    = "~> 1.3.5"
  server_url = "https://acme-v02.api.letsencrypt.org/directory"
}

provider "null" {
  version = "~> 2.1.2"
}

provider "cloudflare" {
  version = "~> 1.16.1"
  email   = var.cloudflare_email
  token   = var.cloudflare_token
}

provider "tls" {
  version = "~> 2.0.1"
}

provider "github" {
  version      = "~> 2.2.0"
  organization = var.github_org
  token        = var.github_token
}

provider "datadog" {
  version = "~> 1.9"
  api_key = var.datadog_api_key
  app_key = var.datadog_app_key
}


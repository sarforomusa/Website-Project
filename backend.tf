# Backend configuration

terraform {
  backend "s3" {
    bucket = "websit-project-bucket"
    key    = "terraform.tfstate"
    region = "eu-west-2"
  }
}
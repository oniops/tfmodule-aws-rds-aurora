terraform {
  required_version = ">= 1.4.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "> 4.50.0, < 6.0.0"
    }
  }
}

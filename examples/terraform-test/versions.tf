terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.50.0, < 6.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 2.3.0"
    }
  }
}

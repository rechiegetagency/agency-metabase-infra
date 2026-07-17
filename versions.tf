terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }

  # Local state for now. To move to a remote backend later, add a
  # `backend "s3" {}` block here and run `terraform init -migrate-state`.
}

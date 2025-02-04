terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    harness = {
      source  = "harness/harness"
      version = "~> 0.30"
    }
  }
}

provider "aws" {
  region = "us-west-1"
  default_tags {
    tags = {
      owner = "riley.snyder@harness.io"
      ttl   = "-1"
    }
  }
}

provider "harness" {}
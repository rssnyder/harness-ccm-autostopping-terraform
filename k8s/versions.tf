terraform {
  required_providers {
    harness = {
      source  = "harness/harness"
      version = "~> 0.30"
    }
  }
}

provider "harness" {}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}
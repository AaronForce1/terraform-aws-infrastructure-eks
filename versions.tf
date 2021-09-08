terraform {
  required_version = ">= 0.14.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.57"
    }
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = "~> 3.4"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}
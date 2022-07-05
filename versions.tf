terraform {
  required_version = ">= 1.0"
  experiments      = [module_variable_optional_attrs]

  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "~> 4.5"
      configuration_aliases = [aws.secondary]
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
      version = "~> 2.11.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14.0"
    }
  }
}
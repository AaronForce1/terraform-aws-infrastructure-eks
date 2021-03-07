provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile

  assume_role {
    role_arn    = var.serviceaccount_role
    external_id = "infrastructure-eks-terraform"
  }
}

provider "gitlab" {
  base_url = "https://gitlab.com/api/v4/"
  token    = var.gitlab_token
}
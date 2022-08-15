module "infrastructure-terraform-eks" {
  source = "../.."

  aws_region       = "ap-southeast-1"
  tfenv            = "example-testing-basic"
  root_domain_name = "basic.example.com"
}

module "gitlab_runner" {
  source     = "./gitlab-runner"
  depends_on = [module.infrastructure-terraform-eks]

  app_name                         = var.app_name
  app_namespace                    = var.app_namespace
  tfenv                            = var.tfenv
  aws_region                       = var.aws_region
  gitlab_serviceaccount_id         = var.gitlab_serviceaccount_id
  gitlab_serviceaccount_secret     = var.gitlab_serviceaccount_secret
  CI_RUNNER_REVISION               = var.CI_RUNNER_REVISION
  gitlab_runner_concurrent_agents  = var.gitlab_runner_concurrent_agents
  gitlab_runner_registration_token = var.gitlab_runner_registration_token
}
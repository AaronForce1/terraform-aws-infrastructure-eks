module "infrastructure-terraform-eks" {
  source = "../.."

  aws_region       = "ap-southeast-1"
  tfenv            = "example-testing-basic"
  root_domain_name = "basic.example.com"
}

module "gitlab-management" {
  source     = "./gitlab-management"
  depends_on = [module.infrastructure-terraform-eks]

  gitlab_token              = var.gitlab_token
  gitlab_namespace          = var.gitlab_namespace
  app_namespace             = var.app_namespace
  tfenv                     = var.tfenv
  eks                       = module.infrastructure-terraform-eks
  root_domain_name          = var.root_domain_name
  cluster_environment_scope = var.cluster_environment_scope
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
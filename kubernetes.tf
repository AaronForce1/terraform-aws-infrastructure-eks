module "namespaces" {
  source     = "./provisioning/kubernetes/namespaces"
  depends_on = [module.eks]

  helm_installations = var.helm_installations
}

module "nginx-controller-ingress" {
  source     = "./provisioning/kubernetes/nginx-controller"
  depends_on = [module.eks, module.namespaces]
  count      = var.helm_installations.ingress ? 1 : 0

  root_domain_name = var.root_domain_name
  app_namespace    = var.app_namespace
  tfenv            = var.tfenv
}

module "certmanager" {
  source     = "./provisioning/kubernetes/certmanager"
  depends_on = [module.eks, module.namespaces, module.nginx-controller-ingress]
  count      = var.helm_installations.ingress ? 1 : 0
}

module "aws-support" {
  source     = "./provisioning/kubernetes/aws-support"
  depends_on = [module.eks, module.eks-vpc]
}

module "aws-cluster-autoscaler" {
  source     = "./provisioning/kubernetes/cluster-autoscaler"
  depends_on = [module.eks]

  app_name                = var.app_name
  app_namespace           = var.app_namespace
  tfenv                   = var.tfenv
  cluster_oidc_issuer_url = module.eks.cluster_oidc_issuer_url
  aws_region              = var.aws_region
}

module "kubernetes-dashboard" {
  source     = "./provisioning/kubernetes/kubernetes-dashboard"
  depends_on = [module.eks-vpc, module.eks, module.namespaces]

  app_namespace = var.app_namespace
  tfenv         = var.tfenv
}

module "vault" {
  source     = "./provisioning/kubernetes/hashicorp-vault"
  depends_on = [module.eks-vpc, module.eks, module.namespaces, module.nginx-controller-ingress, module.certmanager]
  count      = var.helm_installations.vault_consul ? 1 : 0

  app_namespace           = var.app_namespace
  tfenv                   = var.tfenv
  root_domain_name        = var.root_domain_name
  app_name                = var.app_name
  billingcustomer         = var.billingcustomer
  aws_region              = var.aws_region
  enable_aws_vault_unseal = var.enable_aws_vault_unseal
}

module "consul" {
  source     = "./provisioning/kubernetes/hashicorp-consul"
  depends_on = [module.eks-vpc, module.eks, module.namespaces, module.nginx-controller-ingress, module.certmanager]
  count      = var.helm_installations.vault_consul ? 1 : 0

  app_namespace    = var.app_namespace
  tfenv            = var.tfenv
  root_domain_name = var.root_domain_name
  app_name         = var.app_name
}

module "elastic-stack" {
  source     = "./provisioning/kubernetes/elastic-stack"
  depends_on = [module.eks, module.namespaces, module.nginx-controller-ingress, module.certmanager]
  count      = var.helm_installations.elasticstack ? 1 : 0

  app_namespace       = var.app_namespace
  tfenv               = var.tfenv
  root_domain_name    = var.root_domain_name
  google_clientID     = var.google_clientID
  google_clientSecret = var.google_clientSecret
  google_authDomain   = var.google_authDomain
  billingcustomer     = var.billingcustomer
  app_name            = var.app_name
  aws_region          = var.aws_region
}

module "grafana" {
  source     = "./provisioning/kubernetes/grafana"
  depends_on = [module.eks, module.namespaces, module.nginx-controller-ingress, module.certmanager]
  count      = var.helm_installations.grafana ? 1 : 0

  app_namespace       = var.app_namespace
  tfenv               = var.tfenv
  root_domain_name    = var.root_domain_name
  google_clientID     = var.google_clientID
  google_clientSecret = var.google_clientSecret
  google_authDomain   = var.google_authDomain
}

module "gitlab_runner" {
  source     = "./provisioning/kubernetes/gitlab-runner"
  depends_on = [module.namespaces, module.eks, module.eks-vpc]
  count      = var.helm_installations.gitlab_runner ? 1 : 0

  app_name                         = var.app_name
  app_namespace                    = var.app_namespace
  tfenv                            = var.tfenv
  aws_region                       = var.aws_region

  ## Gitlab Runner Configuration
  gitlab_runner_concurrent_agents  = var.gitlab_runner_configuration.concurrent_agents
  gitlab_runner_registration_url   = var.gitlab_runner_configuration.url
  gitlab_runner_registration_token = var.gitlab_runner_registration_token
}
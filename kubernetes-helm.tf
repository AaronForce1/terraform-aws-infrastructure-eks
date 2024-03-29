module "nginx-controller-ingress" {
  source     = "./provisioning/kubernetes/nginx-controller"
  depends_on = [module.eks, resource.aws_route53_zone.hosted_zone]
  count      = var.helm_installations.ingress ? 1 : 0

  cluster_root_domain                  = var.cluster_root_domain
  app_namespace                        = var.app_namespace
  app_name                             = var.app_name
  tfenv                                = var.tfenv
  infrastructure_eks_terraform_version = local.module_version
  billingcustomer                      = var.billingcustomer

  custom_manifest = try(var.helm_configurations.ingress.nginx_values, null)
  ingress_records = var.cluster_root_domain.ingress_records != null ? var.cluster_root_domain.ingress_records : []
}

module "certmanager" {
  source     = "./provisioning/kubernetes/certmanager"
  depends_on = [module.eks]
  count      = var.helm_installations.ingress ? 1 : 0

  custom_manifest   = try(var.helm_configurations.ingress.certmanager_values, null)
  letsencrypt_email = var.tech_email
}

module "kubernetes-dashboard" {
  source     = "./provisioning/kubernetes/kubernetes-dashboard"
  depends_on = [module.eks]
  count      = var.helm_installations.dashboard ? 1 : 0

  app_namespace = var.app_namespace
  tfenv         = var.tfenv

  custom_manifest = var.helm_configurations.dashboard
}

module "consul" {
  source     = "./provisioning/kubernetes/hashicorp-consul"
  depends_on = [module.eks]
  count      = var.helm_installations.vault_consul ? 1 : 0

  vault_nodeselector = try(var.helm_configurations.vault_consul.vault_nodeselector, "") != null ? var.helm_configurations.vault_consul.vault_nodeselector : ""
  vault_tolerations  = try(var.helm_configurations.vault_consul.vault_tolerations, "") != null ? var.helm_configurations.vault_consul.vault_tolerations : ""

  app_namespace    = var.app_namespace
  tfenv            = var.tfenv
  root_domain_name = var.cluster_root_domain.name
  app_name         = var.app_name
  tags             = local.base_tags
}
module "vault" {
  source     = "./provisioning/kubernetes/hashicorp-vault"
  depends_on = [module.eks]
  count      = var.helm_installations.vault_consul ? 1 : 0

  vault_nodeselector      = try(var.helm_configurations.vault_consul.vault_nodeselector, "") != null ? var.helm_configurations.vault_consul.vault_nodeselector : ""
  vault_tolerations       = try(var.helm_configurations.vault_consul.vault_tolerations, "") != null ? var.helm_configurations.vault_consul.vault_tolerations : ""
  app_namespace           = var.app_namespace
  tfenv                   = var.tfenv
  root_domain_name        = var.cluster_root_domain.name
  app_name                = var.app_name
  billingcustomer         = var.billingcustomer
  aws_region              = var.aws_region
  enable_aws_vault_unseal = try(var.helm_configurations.vault_consul.enable_aws_vault_unseal, false) != null ? var.helm_configurations.vault_consul.enable_aws_vault_unseal : false
  tags                    = local.base_tags

  custom_manifest = var.helm_configurations.vault_consul
}

module "vault-secrets-webhook" {
  source     = "./provisioning/kubernetes/bonzai-vault-secrets-webhook"
  depends_on = [module.eks, module.vault]
  count      = var.helm_installations.vault_consul ? 1 : 0

  vault_nodeselector = try(var.helm_configurations.vault_consul.vault_nodeselector, "") != null ? var.helm_configurations.vault_consul.vault_nodeselector : ""
  vault_tolerations  = try(var.helm_configurations.vault_consul.vault_tolerations, "") != null ? var.helm_configurations.vault_consul.vault_tolerations : ""
  app_namespace      = var.app_namespace
  tfenv              = var.tfenv
}

module "vault-operator" {
  source     = "./provisioning/kubernetes/bonzai-vault-operator"
  depends_on = [module.eks, module.vault]
  count      = var.helm_installations.vault_consul ? 1 : 0

  vault_nodeselector = try(var.helm_configurations.vault_consul.vault_nodeselector, "") != null ? var.helm_configurations.vault_consul.vault_nodeselector : ""
  vault_tolerations  = try(var.helm_configurations.vault_consul.vault_tolerations, "") != null ? var.helm_configurations.vault_consul.vault_tolerations : ""
  app_namespace      = var.app_namespace
  tfenv              = var.tfenv
}

module "stakater-reloader" {
  source     = "./provisioning/kubernetes/stakater-reloader"
  depends_on = [module.eks]
  count      = var.helm_installations.stakater_reloader ? 1 : 0

  app_namespace = var.app_namespace
  tfenv         = var.tfenv
}

module "metrics-server" {
  source     = "./provisioning/kubernetes/metrics-server"
  depends_on = [module.eks]
  count      = var.helm_installations.metrics_server && !var.helm_installations.monitoring ? 1 : 0

  app_namespace = var.app_namespace
  tfenv         = var.tfenv
}

module "gitlab-k8s-agent" {
  source     = "./provisioning/kubernetes/gitlab-kubernetes-agent"
  depends_on = [module.eks]
  count      = var.helm_installations.gitlab_k8s_agent ? 1 : 0

  app_namespace       = var.app_namespace
  tfenv               = var.tfenv
  gitlab_agent_url    = var.gitlab_kubernetes_agent_config.gitlab_agent_url
  gitlab_agent_secret = var.gitlab_kubernetes_agent_config.gitlab_agent_secret
}

module "elastic-stack" {
  source     = "./provisioning/kubernetes/elastic-stack"
  depends_on = [module.eks]
  count      = var.helm_installations.elasticstack ? 1 : 0

  app_namespace       = var.app_namespace
  tfenv               = var.tfenv
  root_domain_name    = var.cluster_root_domain.name
  google_clientID     = var.google_clientID
  google_clientSecret = var.google_clientSecret
  google_authDomain   = var.google_authDomain
  billingcustomer     = var.billingcustomer
  app_name            = var.app_name
  aws_region          = var.aws_region
  tags                = local.base_tags
}

module "monitoring-stack" {
  source     = "./provisioning/kubernetes/monitoring"
  depends_on = [module.eks]
  count      = var.helm_installations.monitoring ? 1 : 0

  app_namespace       = var.app_namespace
  tfenv               = var.tfenv
  root_domain_name    = var.cluster_root_domain.name
  google_clientID     = var.google_clientID
  google_clientSecret = var.google_clientSecret
  google_authDomain   = var.google_authDomain

  custom_manifest = try(var.helm_configurations.monitoring.values, null)
  custom_version  = try(var.helm_configurations.monitoring.version, null)
}

module "argocd" {
  source     = "./provisioning/kubernetes/argocd"
  count      = var.helm_installations.argocd ? 1 : 0
  depends_on = [module.eks]

  root_domain_name                  = var.cluster_root_domain.name
  operator_domain_name              = var.operator_domain_name
  hosted_zone_id                    = aws_route53_zone.hosted_zone[0].zone_id
  custom_manifest                   = var.helm_configurations.argocd
  repository_secrets                = var.helm_configurations.argocd.repository_secrets
  credential_templates              = var.helm_configurations.argocd.credential_templates
  registry_secrets                  = var.helm_configurations.argocd.registry_secrets
  generate_plugin_repository_secret = var.helm_configurations.argocd.generate_plugin_repository_secret
}

# module "gitlab_runner" {
#   source     = "./provisioning/kubernetes/gitlab-runner"
#   depends_on =  module.eks-vpc]
#   count      = var.helm_installations.gitlab_runner ? 1 : 0

#   app_name                         = var.app_name
#   app_namespace                    = var.app_namespace
#   tfenv                            = var.tfenv
#   aws_region                       = var.aws_region
#   gitlab_serviceaccount_id         = var.gitlab_serviceaccount_id
#   gitlab_serviceaccount_secret     = var.gitlab_serviceaccount_secret
#   gitlab_runner_concurrent_agents  = var.gitlab_runner_concurrent_agents
#   gitlab_runner_registration_token = var.gitlab_runner_registration_token
# }

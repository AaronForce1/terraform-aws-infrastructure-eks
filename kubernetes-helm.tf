module "nginx-controller-ingress" {
  source     = "./provisioning/kubernetes/nginx-controller"
  depends_on = [resource.aws_eks_node_group.custom_node_group]
  count      = var.helm_installations.ingress ? 1 : 0

  root_domain_name                     = var.cluster_root_domain.name
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
  depends_on = [resource.aws_eks_node_group.custom_node_group, module.nginx-controller-ingress]
  count      = var.helm_installations.ingress ? 1 : 0

  custom_manifest = try(var.helm_configurations.ingress.certmanager_values, null)
}

module "kubernetes-dashboard" {
  source     = "./provisioning/kubernetes/kubernetes-dashboard"
  depends_on = [resource.aws_eks_node_group.custom_node_group]
  count      = var.helm_installations.dashboard ? 1 : 0

  app_namespace = var.app_namespace
  tfenv         = var.tfenv

  custom_manifest = var.helm_configurations.dashboard
}

module "consul" {
  source     = "./provisioning/kubernetes/hashicorp-consul"
  depends_on = [resource.aws_eks_node_group.custom_node_group, resource.kubernetes_namespace.cluster]
  count      = var.helm_installations.vault_consul ? 1 : 0

  app_namespace    = var.app_namespace
  tfenv            = var.tfenv
  root_domain_name = var.cluster_root_domain.name
  app_name         = var.app_name
}
module "vault" {
  source     = "./provisioning/kubernetes/hashicorp-vault"
  depends_on = [resource.aws_eks_node_group.custom_node_group, module.consul]
  count      = var.helm_installations.vault_consul ? 1 : 0

  vault_nodeselector      = try(var.helm_configurations.vault_consul.vault_nodeselector, "") != null ? var.helm_configurations.vault_consul.vault_nodeselector : ""
  app_namespace           = var.app_namespace
  tfenv                   = var.tfenv
  root_domain_name        = var.cluster_root_domain.name
  app_name                = var.app_name
  billingcustomer         = var.billingcustomer
  aws_region              = var.aws_region
  enable_aws_vault_unseal = try(var.helm_configurations.vault_consul.enable_aws_vault_unseal, false) != null ? var.helm_configurations.vault_consul.enable_aws_vault_unseal : false

  custom_manifest = var.helm_configurations.vault_consul
}

module "elastic-stack" {
  source     = "./provisioning/kubernetes/elastic-stack"
  depends_on = [resource.aws_eks_node_group.custom_node_group, resource.kubernetes_namespace.cluster, module.nginx-controller-ingress, module.certmanager]
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
}

module "grafana" {
  source     = "./provisioning/kubernetes/grafana"
  depends_on = [resource.aws_eks_node_group.custom_node_group, resource.kubernetes_namespace.cluster, module.nginx-controller-ingress, module.certmanager]
  count      = var.helm_installations.grafana ? 1 : 0

  app_namespace       = var.app_namespace
  tfenv               = var.tfenv
  root_domain_name    = var.cluster_root_domain.name
  google_clientID     = var.google_clientID
  google_clientSecret = var.google_clientSecret
  google_authDomain   = var.google_authDomain

  custom_manifest = var.helm_configurations.grafana
}

module "argocd" {
  source     = "./provisioning/kubernetes/argocd"
  count      = var.helm_installations.argocd ? 1 : 0
  depends_on = [resource.aws_eks_node_group.custom_node_group]

  custom_manifest  = var.helm_configurations.argocd
  root_domain_name = var.cluster_root_domain.name
}

# module "gitlab_runner" {
#   source     = "./provisioning/kubernetes/gitlab-runner"
#   depends_on = [module.namespaces, module.eks-vpc]
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

resource "kubernetes_namespace" "cluster" {
  depends_on = [module.eks, resource.aws_eks_node_group.custom_node_group]
  for_each   = toset(local.namespaces)

  metadata {
    labels = {
      name              = each.key
      "Terraform"       = true
      "eks/name"        = local.name_prefix
      "eks/environment" = var.tfenv
    }
    name = each.key
  }
}

module "nginx-controller-ingress" {
  source     = "./provisioning/kubernetes/nginx-controller"
  depends_on = [module.eks, resource.aws_eks_node_group.custom_node_group]
  count      = var.helm_installations.ingress ? 1 : 0

  root_domain_name                     = var.cluster_root_domain.name
  app_namespace                        = var.app_namespace
  app_name                             = var.app_name
  tfenv                                = var.tfenv
  infrastructure_eks_terraform_version = local.module_version
  billingcustomer                      = var.billingcustomer
}

module "certmanager" {
  source     = "./provisioning/kubernetes/certmanager"
  depends_on = [module.eks, resource.aws_eks_node_group.custom_node_group, module.nginx-controller-ingress]

  count = var.helm_installations.ingress ? 1 : 0
}

module "kubernetes-dashboard" {
  source     = "./provisioning/kubernetes/kubernetes-dashboard"
  depends_on = [module.eks, resource.aws_eks_node_group.custom_node_group]
  count      = var.helm_installations.dashboard ? 1 : 0

  app_namespace = var.app_namespace
  tfenv         = var.tfenv
}

module "consul" {
  source     = "./provisioning/kubernetes/hashicorp-consul"
  depends_on = [module.eks, resource.aws_eks_node_group.custom_node_group, resource.kubernetes_namespace.cluster]
  count      = var.helm_installations.vault_consul ? 1 : 0

  app_namespace    = var.app_namespace
  tfenv            = var.tfenv
  root_domain_name = var.cluster_root_domain.name
  app_name         = var.app_name
}
module "vault" {
  source     = "./provisioning/kubernetes/hashicorp-vault"
  depends_on = [module.eks, resource.aws_eks_node_group.custom_node_group, module.consul]
  count      = var.helm_installations.vault_consul ? 1 : 0

  vault_nodeselector      = var.vault_nodeselector
  app_namespace           = var.app_namespace
  tfenv                   = var.tfenv
  root_domain_name        = var.cluster_root_domain.name
  app_name                = var.app_name
  billingcustomer         = var.billingcustomer
  aws_region              = var.aws_region
  enable_aws_vault_unseal = var.enable_aws_vault_unseal
}

module "elastic-stack" {
  source     = "./provisioning/kubernetes/elastic-stack"
  depends_on = [module.eks, resource.aws_eks_node_group.custom_node_group, resource.kubernetes_namespace.cluster, module.nginx-controller-ingress, module.certmanager]
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
  depends_on = [module.eks, resource.aws_eks_node_group.custom_node_group, resource.kubernetes_namespace.cluster, module.nginx-controller-ingress, module.certmanager]
  count      = var.helm_installations.grafana ? 1 : 0

  app_namespace       = var.app_namespace
  tfenv               = var.tfenv
  root_domain_name    = var.cluster_root_domain.name
  google_clientID     = var.google_clientID
  google_clientSecret = var.google_clientSecret
  google_authDomain   = var.google_authDomain
}

module "argocd" {
  source     = "./provisioning/kubernetes/argocd"
  count      = var.helm_installations.argocd ? 1 : 0
  depends_on = [module.eks, resource.aws_eks_node_group.custom_node_group]

  custom_manifest  = var.helm_configurations.argocd
  root_domain_name = var.cluster_root_domain.name
}

# module "gitlab_runner" {
#   source     = "./provisioning/kubernetes/gitlab-runner"
#   depends_on = [module.namespaces, module.eks, module.eks-vpc]
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

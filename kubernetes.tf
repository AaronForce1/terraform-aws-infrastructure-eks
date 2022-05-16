module "namespaces" {
  source     = "./provisioning/kubernetes/namespaces"
  depends_on = [module.eks, aws_eks_node_group.custom_node_group]

  helm_installations = var.helm_installations
}

module "nginx-controller-ingress" {
  source     = "./provisioning/kubernetes/nginx-controller"
  depends_on = [module.eks, aws_eks_node_group.custom_node_group, module.namespaces]
  count      = var.helm_installations.ingress ? 1 : 0

  root_domain_name                     = var.root_domain_name
  app_namespace                        = var.app_namespace
  app_name                             = var.app_name
  tfenv                                = var.tfenv
  infrastructure_eks_terraform_version = local.module_version
  billingcustomer                      = var.billingcustomer
}

module "certmanager" {
  source     = "./provisioning/kubernetes/certmanager"
  depends_on = [module.eks, aws_eks_node_group.custom_node_group, module.namespaces, module.nginx-controller-ingress]

  count = var.helm_installations.ingress ? 1 : 0
  letsencrypt_email = var.letsencrypt_email
}

module "aws-support" {
  source     = "./provisioning/kubernetes/aws-support"
  depends_on = [module.eks, module.eks-vpc, module.subnet_addrs]

  vpc_id          = module.eks-vpc.vpc_id
  cidr_blocks     = module.eks-vpc.private_subnets_cidr_blocks
  oidc_url        = module.eks.cluster_oidc_issuer_url
  account_id      = data.aws_caller_identity.current.account_id
  aws_region      = var.aws_region
  app_name        = var.app_name
  app_namespace   = var.app_namespace
  tfenv           = var.tfenv
  base_cidr_block = module.subnet_addrs.base_cidr_block
  billingcustomer = var.billingcustomer
  node_count      = length(var.managed_node_groups) > 0 ? var.managed_node_groups[0].min_capacity : var.instance_min_size
  tags            = local.tags
}

module "aws-cluster-autoscaler" {
  source     = "./provisioning/kubernetes/cluster-autoscaler"
  depends_on = [module.eks, aws_eks_node_group.custom_node_group]

  app_name                      = var.app_name
  app_namespace                 = var.app_namespace
  tfenv                         = var.tfenv
  cluster_oidc_issuer_url       = module.eks.cluster_oidc_issuer_url
  aws_region                    = var.aws_region
  scale_down_util_threshold     = var.aws_autoscaler_scale_down_util_threshold
  skip_nodes_with_local_storage = var.aws_autoscaler_skip_nodes_with_local_storage
  skip_nodes_with_system_pods   = var.aws_autoscaler_skip_nodes_with_system_pods
  cordon_node_before_term       = var.aws_autoscaler_cordon_node_before_term
  tags                          = local.tags
}

module "kubernetes-dashboard" {
  source     = "./provisioning/kubernetes/kubernetes-dashboard"
  depends_on = [module.eks-vpc, module.eks, aws_eks_node_group.custom_node_group, module.namespaces]

  app_namespace = var.app_namespace
  tfenv         = var.tfenv
}

module "vault" {
  source     = "./provisioning/kubernetes/hashicorp-vault"
  depends_on = [module.eks-vpc, module.eks, aws_eks_node_group.custom_node_group, module.namespaces, module.nginx-controller-ingress, module.certmanager]
  count      = var.helm_installations.vault_consul ? 1 : 0

  vault_nodeselector      = var.vault_nodeselector
  vault_tolerations       = var.vault_tolerations
  app_namespace           = var.app_namespace
  tfenv                   = var.tfenv
  root_domain_name        = var.root_domain_name
  app_name                = var.app_name
  billingcustomer         = var.billingcustomer
  aws_region              = var.aws_region
  enable_aws_vault_unseal = var.enable_aws_vault_unseal
  tags                    = local.tags
}

module "vault-secrets-webhook" {
  source     = "./provisioning/kubernetes/bonzai-vault-secrets-webhook"
  depends_on = [module.eks-vpc, module.eks, aws_eks_node_group.custom_node_group, module.namespaces, module.nginx-controller-ingress, module.certmanager]
  count      = var.helm_installations.vault_consul ? 1 : 0

  vault_nodeselector      = var.vault_nodeselector
  vault_tolerations       = var.vault_tolerations
  app_namespace           = var.app_namespace
  tfenv                   = var.tfenv
}

module "vault-operator" {
  source     = "./provisioning/kubernetes/bonzai-vault-operator"
  depends_on = [module.eks-vpc, module.eks, aws_eks_node_group.custom_node_group, module.namespaces, module.nginx-controller-ingress, module.certmanager]
  count      = var.helm_installations.vault_consul ? 1 : 0

  vault_nodeselector      = var.vault_nodeselector
  vault_tolerations       = var.vault_tolerations
  app_namespace           = var.app_namespace
  tfenv                   = var.tfenv
}

module "consul" {
  source     = "./provisioning/kubernetes/hashicorp-consul"
  depends_on = [module.eks-vpc, module.eks, aws_eks_node_group.custom_node_group, module.namespaces, module.nginx-controller-ingress, module.certmanager]
  count      = var.helm_installations.vault_consul ? 1 : 0

  vault_nodeselector      = var.vault_nodeselector
  vault_tolerations       = var.vault_tolerations
  app_namespace    = var.app_namespace
  tfenv            = var.tfenv
  root_domain_name = var.root_domain_name
  app_name         = var.app_name
}

module "elastic-stack" {
  source     = "./provisioning/kubernetes/elastic-stack"
  depends_on = [module.eks, aws_eks_node_group.custom_node_group, module.namespaces, module.nginx-controller-ingress, module.certmanager]
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
  tags                = local.tags
}

module "stakater-reloader" {
  source     = "./provisioning/kubernetes/stakater-reloader"
  depends_on = [module.eks-vpc, module.eks, aws_eks_node_group.custom_node_group, module.namespaces, module.nginx-controller-ingress, module.certmanager]
  count      = var.helm_installations.stakater_reloader ? 1 : 0

  app_namespace    = var.app_namespace
  tfenv            = var.tfenv
}

module "metrics-server" {
  source     = "./provisioning/kubernetes/metrics-server"
  depends_on = [module.eks-vpc, module.eks, aws_eks_node_group.custom_node_group, module.namespaces, module.nginx-controller-ingress, module.certmanager]
  count      = var.helm_installations.metrics_server ? 1 : 0

  app_namespace    = var.app_namespace
  tfenv            = var.tfenv
}

module "grafana" {
  source     = "./provisioning/kubernetes/grafana"
  depends_on = [module.eks, aws_eks_node_group.custom_node_group, module.namespaces, module.nginx-controller-ingress, module.certmanager]
  count      = var.helm_installations.grafana ? 1 : 0

  app_namespace       = var.app_namespace
  tfenv               = var.tfenv
  root_domain_name    = var.root_domain_name
  google_clientID     = var.google_clientID
  google_clientSecret = var.google_clientSecret
  google_authDomain   = var.google_authDomain
}

module "gitlab-k8s-agent" {
  source     = "./provisioning/kubernetes/gitlab-kubernetes-agent"
  depends_on = [module.eks, aws_eks_node_group.custom_node_group, module.namespaces]
  count      = var.helm_installations.gitlab_k8s_agent ? 1 : 0

  app_namespace          = var.app_namespace
  tfenv                  = var.tfenv
  gitlab_agent_url       = var.gitlab_kubernetes_agent_config.gitlab_agent_url
  gitlab_agent_secret    = var.gitlab_kubernetes_agent_config.gitlab_agent_secret
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

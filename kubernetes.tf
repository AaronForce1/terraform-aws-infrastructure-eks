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
  depends_on = [module.eks]
}

module "kubernetes-dashboard" {
  source     = "./provisioning/kubernetes/kubernetes-dashboard"
  depends_on = [module.eks, module.namespaces]

  app_namespace = var.app_namespace
  tfenv         = var.tfenv
}

module "vault" {
  source     = "./provisioning/kubernetes/hashicorp-vault"
  depends_on = [module.eks, module.namespaces, module.nginx-controller-ingress, module.certmanager]
  count      = var.helm_installations.vault_consul ? 1 : 0

  app_namespace    = var.app_namespace
  tfenv            = var.tfenv
  root_domain_name = var.root_domain_name
  app_name         = var.app_name
}

module "consul" {
  source     = "./provisioning/kubernetes/hashicorp-consul"
  depends_on = [module.eks, module.namespaces, module.nginx-controller-ingress, module.certmanager]
  count      = var.helm_installations.vault_consul ? 1 : 0

  app_namespace    = var.app_namespace
  tfenv            = var.tfenv
  root_domain_name = var.root_domain_name
  app_name         = var.app_name
}
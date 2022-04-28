module "aws-support" {
  source     = "./aws-support"
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
  node_count      = var.instance_min_size # var.eks_managed_node_groups != null ? var.eks_managed_node_groups[keys(var.eks_managed_node_groups)[0]].min_capacity : var.instance_min_size
}

module "aws-cluster-autoscaler" {
  source     = "./aws-cluster-autoscaler"
  depends_on = [module.eks]

  app_name                = var.app_name
  app_namespace           = var.app_namespace
  tfenv                   = var.tfenv
  cluster_oidc_issuer_url = module.eks.cluster_oidc_issuer_url
  aws_region              = var.aws_region
}
module "eks" {
  source     = "terraform-aws-modules/eks/aws"
  version    = "~> 17.15.0"
  depends_on = [module.eks-vpc]

  cluster_name    = local.name_prefix
  cluster_version = var.cluster_version

  vpc_id  = module.eks-vpc.vpc_id
  subnets = concat(module.eks-vpc.public_subnets, module.eks-vpc.private_subnets)

  cluster_endpoint_private_access       = true
  cluster_endpoint_private_access_cidrs = module.eks-vpc.private_subnets_cidr_blocks
  cluster_endpoint_public_access        = length(var.cluster_endpoint_public_access_cidrs) > 0 ? true : false
  cluster_endpoint_public_access_cidrs  = var.cluster_endpoint_public_access_cidrs

  cluster_encryption_config = [{
    provider_key_arn = aws_kms_key.eks.arn
    resources        = ["secrets"]
  }]

  node_groups_defaults = {
    ami_type  = var.default_ami_type
    disk_size = var.root_vol_size
  }

  cluster_enabled_log_types = ["api", "authenticator", "audit", "scheduler", "controllerManager"]

  node_groups = length(var.eks_managed_node_groups) > 0 ? {} : local.default_node_group # != null ? var.eks_managed_node_groups : local.default_node_group

  enable_irsa = true

  map_roles    = concat(var.map_roles, local.default_aws_auth_roles)
  map_users    = var.map_users
  map_accounts = var.map_accounts

  tags = {
    Environment                  = var.tfenv
    Terraform                    = "true"
    Namespace                    = var.app_namespace
    Billingcustomer              = var.billingcustomer
    Product                      = var.app_name
    infrastructure-eks-terraform = local.module_version
  }
}

resource "aws_kms_key" "eks" {
  description             = "${local.name_prefix} EKS Encryption Key"
  multi_region            = "true"
  enable_key_rotation     = true
  deletion_window_in_days = 30
  tags = merge({
    Name = "${local.name_prefix}-key"
  }, local.base_tags)
}

resource "aws_kms_alias" "eks" {
  name          = "alias/${local.name_prefix}-kms"
  target_key_id = aws_kms_key.eks.key_id
}

resource "aws_kms_replica_key" "eks" {
  description             = "${local.name_prefix} EKS Replica Key (Multi-Region)"
  deletion_window_in_days = 30
  primary_key_arn         = aws_kms_key.eks.arn
  provider                = aws.secondary
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 18.23.0"

  cluster_name    = local.name_prefix
  cluster_version = var.cluster_version

  vpc_id     = module.eks-vpc.vpc_id
  subnet_ids = concat(module.eks-vpc.public_subnets, module.eks-vpc.private_subnets)

  cluster_endpoint_private_access = true
  # cluster_endpoint_private_access_cidrs = module.eks-vpc.private_subnets_cidr_blocks
  cluster_endpoint_public_access       = length(var.cluster_endpoint_public_access_cidrs) > 0 ? true : false
  cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs

  # IPV6
  # cluster_ip_family = "ipv6" # NOT READY YET

  # We are using the IRSA created below for permissions
  # However, we have to deploy with the policy attached FIRST (when creating a fresh cluster)
  # and then turn this off after the cluster/node group is created. Without this initial policy,
  # the VPC CNI fails to assign IPs and nodes cannot join the cluster
  # See https://github.com/aws/containers-roadmap/issues/1666 for more context
  # TODO - remove this policy once AWS releases a managed version similar to AmazonEKS_CNI_Policy (IPv4)
  # create_cni_ipv6_iam_policy = true

  cluster_addons = var.cluster_addons

  cluster_encryption_config = [{
    provider_key_arn = aws_kms_key.eks.arn
    resources        = ["secrets"]
  }]

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    ami_type = var.default_ami_type

    attach_cluster_primary_security_group = true

    # We are using the IRSA created below for permissions
    # However, we have to deploy with the policy attached FIRST (when creating a fresh cluster)
    # and then turn this off after the cluster/node group is created. Without this initial policy,
    # the VPC CNI fails to assign IPs and nodes cannot join the cluster
    # See https://github.com/aws/containers-roadmap/issues/1666 for more context
    iam_role_attach_cni_policy = true
  }

  eks_managed_node_groups = length(var.eks_managed_node_groups) > 0 ? {} : local.default_node_group

  cluster_enabled_log_types = ["api", "authenticator", "audit", "scheduler", "controllerManager"]

  enable_irsa = true

  create_aws_auth_configmap = false
  manage_aws_auth_configmap = false

  # aws_auth_roles    = local.default_aws_auth_roles
  # aws_auth_users    = var.map_users
  # aws_auth_accounts = var.map_accounts

  cluster_tags = local.base_tags
  tags = {
    Environment                  = var.tfenv
    Terraform                    = "true"
    Namespace                    = var.app_namespace
    Billingcustomer              = var.billingcustomer
    Product                      = var.app_name
    infrastructure-eks-terraform = local.module_version
  }
}

resource "aws_iam_policy" "node_additional" {
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "additional" {
  for_each = module.eks.eks_managed_node_groups

  policy_arn = aws_iam_policy.node_additional.arn
  role       = each.value.iam_role_name
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

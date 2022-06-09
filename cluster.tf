module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 18.23.0"

  ### This causes the issue!!!
  # depends_on = [
  #   ## VPC COMPONENTS
  #   module.eks-vpc,

  #   ## KMS
  #   resource.aws_kms_key.eks,
  #   resource.aws_kms_alias.eks,
  #   resource.aws_kms_replica_key.eks,
  # ]

  cluster_name    = local.name_prefix
  cluster_version = var.cluster_version

  vpc_id  = module.eks-vpc.vpc_id
  subnet_ids = concat(module.eks-vpc.public_subnets, module.eks-vpc.private_subnets)

  cluster_endpoint_private_access       = true
  # cluster_endpoint_private_access_cidrs = module.eks-vpc.private_subnets_cidr_blocks
  cluster_endpoint_public_access        = length(var.cluster_endpoint_public_access_cidrs) > 0 ? true : false
  cluster_endpoint_public_access_cidrs  = var.cluster_endpoint_public_access_cidrs

  cluster_encryption_config = [{
    provider_key_arn = aws_kms_key.eks.arn
    resources        = ["secrets"]
  }]

  cluster_enabled_log_types = ["api", "authenticator", "audit", "scheduler", "controllerManager"]
  
  eks_managed_node_groups = var.eks_managed_node_groups

  enable_irsa = true

  # map_roles    = concat(var.map_roles, local.default_aws_auth_roles)
  # map_users    = var.map_users
  # map_accounts = var.map_accounts

  tags = {
    Environment                  = var.tfenv
    Terraform                    = "true"
    Namespace                    = var.app_namespace
    Billingcustomer              = var.billingcustomer
    Product                      = var.app_name
    infrastructure-eks-terraform = local.module_version
  }
}

resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
    labels = {
      "app.kubernetes.io/managed-by" : "terraform"
    }
  }

  data = {
    mapRoles : yamlencode(concat(var.map_roles, [for group in module.eks.eks_managed_node_groups : {
      "groups" : ["system:bootstrappers", "system:nodes"],
      "rolearn": group.iam_role_arn
      "username" : "system:node:{{EC2PrivateDNSName}}"
    }]))
    mapAccounts : yamlencode(var.map_accounts)
    mapUsers : yamlencode(var.map_users)
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
  role       = each.value.iam_role_arn
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

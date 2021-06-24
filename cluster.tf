module "eks" {
  source     = "terraform-aws-modules/eks/aws"
  version    = "~> 15.2.0"
  depends_on = [module.eks-vpc]

  cluster_name = "${var.app_name}-${var.app_namespace}-${var.tfenv}"
  # https://docs.gitlab.com/ee/user/project/clusters/#supported-cluster-versions
  cluster_version    = var.cluster_version
  subnets            = concat(module.eks-vpc.public_subnets, module.eks-vpc.private_subnets)
  write_kubeconfig   = "true"
  config_output_path = "./.kubeconfig.${var.app_name}_${var.app_namespace}_${var.tfenv}"
  tags = {
    Terraform                    = "true"
    Environment                  = var.tfenv
    Product                      = var.app_name
    billingcustomer              = var.billingcustomer
    Namespace                    = var.app_namespace
    infrastructure-terraform-eks = data.local_file.infrastructure-terraform-eks-version.content
  }
  vpc_id = module.eks-vpc.vpc_id

  cluster_endpoint_private_access       = true
  cluster_endpoint_private_access_cidrs = module.eks-vpc.public_subnets_cidr_blocks
  cluster_endpoint_public_access        = true

  cluster_enabled_log_types = ["api", "authenticator", "audit", "scheduler", "controllerManager"]
  cluster_encryption_config = [
    {
      provider_key_arn = aws_kms_key.eks.arn
      resources        = ["secrets"]
    }
  ]
  enable_irsa = true

  node_groups_defaults = {
    ami_type  = "AL2_x86_64"
    disk_size = var.root_vol_size
  }

  workers_group_defaults = {
    instance_type = var.instance_type
  }

  node_groups = length(var.managed_node_groups) > 0 ? {} : local.default_node_group

  map_roles    = var.map_roles
  map_users    = var.map_users
  map_accounts = var.map_accounts
}

resource "aws_kms_key" "eks" {
  enable_key_rotation = true
  description         = "${var.app_name}-${var.app_namespace}-${var.tfenv} EKS Secret Encryption Key"
  tags = {
    Environment     = var.tfenv
    Billingcustomer = var.billingcustomer
    Namespace       = var.app_namespace
    Product         = var.app_name
  }
}


data "aws_eks_cluster" "my-cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "my-auth" {
  name = module.eks.cluster_id
}

####################################
##                                ##
##      SUPPLEMENTAL SUPPORT      ##
##    TRADITIONAL INFRA INTEG.    ##
##                                ##
####################################

## TODO: Allow for custom integration with NAT VPC peering to private AWS infrastructure/VPCs.

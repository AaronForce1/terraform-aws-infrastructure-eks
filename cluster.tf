module "eks" {
  source     = "terraform-aws-modules/eks/aws"
  version    = "~> 13.2.1"
  depends_on = [module.eks-vpc]

  cluster_name = "${var.app_name}-${var.app_namespace}-${var.tfenv}"
  # https://docs.gitlab.com/ee/user/project/clusters/#supported-cluster-versions
  cluster_version    = var.cluster_version
  subnets            = module.eks-vpc.private_subnets
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
  cluster_endpoint_private_access_cidrs = module.eks-vpc.private_subnets_cidr_blocks
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
    disk_size = 50
  }

  node_groups = {
    node_public_ip     = var.node_public_ip
    core = {
      desired_capacity = var.instance_desired_size
      max_capacity     = var.instance_max_size
      min_capacity     = var.instance_min_size
      instance_type    = var.instance_type

      k8s_labels = {
        Environment = var.tfenv
      }
      tags = {
        Name                                                                          = "${var.app_name}-${var.app_namespace}-${var.tfenv}"
        Environment                                                                   = var.tfenv
        billingcustomer                                                               = var.billingcustomer
        Namespace                                                                     = var.app_namespace
        Product                                                                       = var.app_name
        Version                                                                       = data.local_file.infrastructure-terraform-eks-version.content
        infrastructure-terraform-eks                                                  = data.local_file.infrastructure-terraform-eks-version.content
        "k8s.io/cluster-autoscaler/enabled"                                           = true
        "k8s.io/cluster-autoscaler/${var.app_name}-${var.app_namespace}-${var.tfenv}" = true
      }
      additional_tags = {
        Name                         = "${var.app_name}-${var.app_namespace}-${var.tfenv}"
        Environment                  = var.tfenv
        billingcustomer              = var.billingcustomer
        Namespace                    = var.app_namespace
        Product                      = var.app_name
        Version                      = data.local_file.infrastructure-terraform-eks-version.content
        infrastructure-terraform-eks = data.local_file.infrastructure-terraform-eks-version.content
      }
    }
  }

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
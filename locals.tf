locals {
  module_version = chomp(data.local_file.infrastructure-terraform-eks-version.content)
}

locals {
  kubernetes_tags = {
      Name                                                                          = "${var.app_name}-${var.app_namespace}-${var.tfenv}"
      Environment                                                                   = var.tfenv
      billingcustomer                                                               = var.billingcustomer
      Namespace                                                                     = var.app_namespace
      Product                                                                       = var.app_name
      Version                                                                       = local.module_version
      infrastructure-terraform-eks                                                  = local.module_version
      "k8s.io/cluster-autoscaler/enabled"                                           = true
      "k8s.io/cluster-autoscaler/${var.app_name}-${var.app_namespace}-${var.tfenv}" = true
  }
  additional_kubernetes_tags = {
      Name                         = "${var.app_name}-${var.app_namespace}-${var.tfenv}"
      Environment                  = var.tfenv
      billingcustomer              = var.billingcustomer
      Namespace                    = var.app_namespace
      Product                      = var.app_name
      infrastructure-terraform-eks = local.module_version
  }


  default_node_group = {
    core = {
      desired_capacity = var.instance_desired_size
      max_capacity     = var.instance_max_size
      min_capacity     = var.instance_min_size
      instance_type   = var.instance_type
      key_name         = var.node_key_name
      public_ip        = var.node_public_ip
      create_launch_template = var.create_launch_template
      disk_size        = "50"
      k8s_labels = {
        Environment = var.tfenv
      }
      tags = local.kubernetes_tags
      additional_tags = local.additional_kubernetes_tags
    }
  }

  default_aws_auth_roles = [
    {
      "groups": ["system:bootstrappers", "system:nodes"],
      "rolearn": module.eks.worker_iam_role_arn,
      "username": "system:node:{{EC2PrivateDNSName}}"
    }
  ]

  base_cidr = var.vpc_subnet_configuration.autogenerate ? format(var.vpc_subnet_configuration.base_cidr, random_integer.cidr_vpc[0].result) : var.vpc_subnet_configuration.base_cidr
}

resource "random_integer" "cidr_vpc" {
  count = var.vpc_subnet_configuration.autogenerate ? 1 : 0
  min = 0
  max = 255
  keepers = {
    name = "eks-${var.app_namespace}-${var.tfenv}-cluster-vpc"
  }
}

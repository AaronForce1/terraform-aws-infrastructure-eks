locals {
  module_version = chomp(data.local_file.infrastructure-terraform-eks-version.content)
}

locals {
  base_tags = {
    Environment                  = var.tfenv
    Terraform                    = "true"
    Namespace                    = var.app_namespace
    Billingcustomer              = var.billingcustomer
    Product                      = var.app_name
    infrastructure-eks-terraform = local.module_version
    Name                         = "${var.app_name}-${var.app_namespace}-${var.tfenv}"
  }
  kubernetes_tags = {
    "k8s.io/cluster-autoscaler/enabled"                                           = true
    "k8s.io/cluster-autoscaler/${var.app_name}-${var.app_namespace}-${var.tfenv}" = true
  }

  tags = merge (local.base_tags, var.extra_tags)


  default_node_group = {
    core = {
      desired_capacity       = var.instance_desired_size
      max_capacity           = var.instance_max_size
      min_capacity           = var.instance_min_size
      instance_type          = var.instance_type
      key_name               = var.node_key_name
      public_ip              = var.node_public_ip
      create_launch_template = var.create_launch_template
      disk_size              = "50"
      k8s_labels = {
        Environment = var.tfenv
      }
      tags            = merge (local.kubernetes_tags,local.tags)
      additional_tags = local.tags
    }
  }

  default_aws_auth_roles = [
    {
      "groups" : ["system:bootstrappers", "system:nodes"],
      "rolearn" : module.eks.worker_iam_role_arn,
      "username" : "system:node:{{EC2PrivateDNSName}}"
    }
  ]

  base_cidr = var.vpc_subnet_configuration.autogenerate ? format(var.vpc_subnet_configuration.base_cidr, random_integer.cidr_vpc[0].result) : var.vpc_subnet_configuration.base_cidr

  nat_gateway_configuration = var.nat_gateway_custom_configuration.enabled ? {
    "enable_nat_gateway"     = var.nat_gateway_custom_configuration.enable_nat_gateway
    "enable_dns_hostnames"   = var.nat_gateway_custom_configuration.enable_dns_hostnames
    "single_nat_gateway"     = var.nat_gateway_custom_configuration.single_nat_gateway
    "one_nat_gateway_per_az" = var.nat_gateway_custom_configuration.one_nat_gateway_per_az
    # reuse_nat_ips                     = true
    # external_nat_ip_ids               = [aws_eip.nat_gw_elastic_ip.id]
    "enable_vpn_gateway"                = var.nat_gateway_custom_configuration.enable_vpn_gateway
    "propagate_public_route_tables_vgw" = var.nat_gateway_custom_configuration.enable_vpn_gateway
    } : {
    enable_nat_gateway     = true
    enable_dns_hostnames   = true
    single_nat_gateway     = var.tfenv == "prod" ? false : true
    one_nat_gateway_per_az = false
    # reuse_nat_ips                     = true
    # external_nat_ip_ids               = [aws_eip.nat_gw_elastic_ip.id]
    enable_vpn_gateway                = false
    propagate_public_route_tables_vgw = false
  }

}

resource "random_integer" "cidr_vpc" {
  count = var.vpc_subnet_configuration.autogenerate ? 1 : 0
  min   = 0
  max   = 255
  keepers = {
    name = "eks-${var.app_namespace}-${var.tfenv}-cluster-vpc"
  }
}

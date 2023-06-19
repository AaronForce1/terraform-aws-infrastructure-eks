locals {
  module_version = chomp(data.local_file.infrastructure-terraform-eks-version.content)
}

locals {
  name_prefix = var.cluster_name != "" ? var.cluster_name : "${var.app_name}-${var.app_namespace}-${var.tfenv}"
  base_tags = {
    Environment                      = var.tfenv
    Terraform                        = "true"
    Version                          = local.module_version
    Namespace                        = var.app_namespace
    Billingcustomer                  = var.billingcustomer
    Product                          = var.app_name
    terraform-aws-infrastructure-eks = local.module_version
  }
  kubernetes_tags = merge({
    Name                                                                          = "${var.app_name}-${var.app_namespace}-${var.tfenv}"
    "k8s.io/cluster-autoscaler/enabled"                                           = true
    "k8s.io/cluster-autoscaler/${var.app_name}-${var.app_namespace}-${var.tfenv}" = true
  }, local.base_tags)
  additional_kubernetes_tags = merge({
    Name = "${var.app_name}-${var.app_namespace}-${var.tfenv}"
  }, local.base_tags)

  default_node_group = {
    core = {
      desired_capacity       = var.instance_desired_size
      max_capacity           = var.instance_max_size
      min_capacity           = var.instance_min_size
      instance_type          = var.instance_type
      key_name               = var.node_key_name
      public_ip              = var.node_public_ip
      create_launch_template = var.create_launch_template
      disk_size              = var.root_vol_size
      k8s_labels = {
        Environment = var.tfenv
      }
      tags            = local.kubernetes_tags
      additional_tags = local.additional_kubernetes_tags
    }
  }

  aws_auth_roles = concat(
    [
      for x in module.eks_managed_node_group :
      {
        "groups" : ["system:bootstrappers", "system:nodes"]
        "rolearn" : x.iam_role_arn
        "username" : "system:node:{{EC2PrivateDNSName}}"
      }
    ],
    var.helm_installations.teleport && try(coalesce(var.aws_installations.teleport.cluster_discovery, false), false) ? [
      {
        "groups" : ["teleport"]
        "rolearn" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.app_name}/${var.app_namespace}/${var.tfenv}/${var.app_name}-${var.app_namespace}-${var.tfenv}-teleport-kube-agent-role"
        "username" : "teleport"
      }
    ] : []
  )

  base_cidr = var.vpc_subnet_configuration.autogenerate ? format(var.vpc_subnet_configuration.base_cidr, random_integer.cidr_vpc[0].result) : var.vpc_subnet_configuration.base_cidr

  nat_gateway_configuration = var.nat_gateway_custom_configuration.enabled ? {
    "enable_nat_gateway"                = var.nat_gateway_custom_configuration.enable_nat_gateway
    "enable_dns_hostnames"              = var.nat_gateway_custom_configuration.enable_dns_hostnames
    "single_nat_gateway"                = var.nat_gateway_custom_configuration.single_nat_gateway
    "one_nat_gateway_per_az"            = var.nat_gateway_custom_configuration.one_nat_gateway_per_az
    "reuse_nat_ips"                     = var.elastic_ip_custom_configuration.enabled ? var.elastic_ip_custom_configuration.reuse_nat_ips : false
    "external_nat_ip_ids"               = var.elastic_ip_custom_configuration.enabled ? var.elastic_ip_custom_configuration.external_nat_ip_ids : []
    "enable_vpn_gateway"                = var.nat_gateway_custom_configuration.enable_vpn_gateway
    "propagate_public_route_tables_vgw" = var.nat_gateway_custom_configuration.enable_vpn_gateway
    } : {
    enable_nat_gateway                = true
    enable_dns_hostnames              = true
    single_nat_gateway                = var.tfenv == "prod" ? false : true
    one_nat_gateway_per_az            = false
    reuse_nat_ips                     = var.elastic_ip_custom_configuration.enabled ? var.elastic_ip_custom_configuration.reuse_nat_ips : false
    external_nat_ip_ids               = var.elastic_ip_custom_configuration.enabled ? var.elastic_ip_custom_configuration.external_nat_ip_ids : []
    enable_vpn_gateway                = false
    propagate_public_route_tables_vgw = false
  }

  namespaces = concat(
    var.custom_namespaces,
    ["monitoring"],
    (var.helm_installations.vault_consul ? ["hashicorp"] : []),
    (var.helm_installations.argocd ? ["argocd"] : [])
  )

  cluster_security_group_additional_rules = {
    for cidr in var.cluster_endpoint_private_access_cidrs :
    "ingress-${cidr}" => {
      description = "ingress for ${cidr}"
      protocol    = "-1"
      from_port   = 443
      to_port     = 443
      type        = "ingress"
      cidr_blocks = [cidr]
    }
  }

  cluster_domains = concat(
    try(var.cluster_root_domain.create, false) ? [] : [var.cluster_root_domain.name],
    coalesce(var.cluster_root_domain.additional_domains, [])
  )
}

resource "random_integer" "cidr_vpc" {
  count = var.vpc_subnet_configuration.autogenerate ? 1 : 0
  min   = 0
  max   = 255
  keepers = {
    name = "eks-${var.app_namespace}-${var.tfenv}-cluster-vpc"
  }
}

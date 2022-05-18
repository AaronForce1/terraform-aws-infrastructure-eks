data "aws_availability_zones" "available" {
  state = "available"
}

module "subnet_addrs" {
  source  = "hashicorp/subnets/cidr"
  version = "1.0.0"

  base_cidr_block = local.base_cidr
  networks = [
    {
      name     = "public-1"
      new_bits = var.vpc_subnet_configuration.subnet_bit_interval
    },
    {
      name     = "public-2"
      new_bits = var.vpc_subnet_configuration.subnet_bit_interval
    },
    {
      name     = "public-3"
      new_bits = var.vpc_subnet_configuration.subnet_bit_interval
    },
    {
      name     = "private-1"
      new_bits = var.vpc_subnet_configuration.subnet_bit_interval
    },
    {
      name     = "private-2"
      new_bits = var.vpc_subnet_configuration.subnet_bit_interval
    },
    {
      name     = "private-3"
      new_bits = var.vpc_subnet_configuration.subnet_bit_interval
    },
  ]
}

module "eks-vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.1"

  name = "eks-${var.app_namespace}-${var.tfenv}-cluster-vpc"
  cidr = module.subnet_addrs.base_cidr_block

  # TODO: Modularise these arrays: https://gitlab.com/nicosingh/medium-deploy-eks-cluster-using-terraform/-/blob/master/network.tf
  azs = [
    data.aws_availability_zones.available.names[0],
    data.aws_availability_zones.available.names[1],
    data.aws_availability_zones.available.names[2]
  ]
  private_subnets = [
    module.subnet_addrs.networks[3].cidr_block,
    module.subnet_addrs.networks[4].cidr_block,
    module.subnet_addrs.networks[5].cidr_block,
  ]
  public_subnets = [
    module.subnet_addrs.networks[0].cidr_block,
    module.subnet_addrs.networks[1].cidr_block,
    module.subnet_addrs.networks[2].cidr_block,
  ]

  # TODO: Configure NAT Gateway setting overrides
  enable_nat_gateway     = local.nat_gateway_configuration.enable_nat_gateway
  enable_dns_hostnames   = local.nat_gateway_configuration.enable_dns_hostnames
  single_nat_gateway     = local.nat_gateway_configuration.single_nat_gateway
  one_nat_gateway_per_az = local.nat_gateway_configuration.one_nat_gateway_per_az
  # reuse_nat_ips                     = true
  # external_nat_ip_ids               = [aws_eip.nat_gw_elastic_ip.id]
  enable_vpn_gateway                = local.nat_gateway_configuration.enable_vpn_gateway
  propagate_public_route_tables_vgw = local.nat_gateway_configuration.propagate_public_route_tables_vgw

  # Manage Default VPC
  manage_default_vpc = false

  # Default security group - ingress/egress rules cleared to deny all
  manage_default_security_group  = false
  default_security_group_ingress = [{}]
  default_security_group_egress  = [{}]

  # VPC Flow Logs (Cloudwatch log group and IAM role will be created)
  enable_flow_log                      = try(var.vpc_flow_logs.enabled, var.tfenv == "prod" ? true : false)
  create_flow_log_cloudwatch_log_group = try(var.vpc_flow_logs.enabled, var.tfenv == "prod" ? true : false)
  create_flow_log_cloudwatch_iam_role  = try(var.vpc_flow_logs.enabled, var.tfenv == "prod" ? true : false)
  flow_log_max_aggregation_interval    = 60

  #IPv6 section
  enable_ipv6                                    = var.ipv6.enable
  assign_ipv6_address_on_creation                = var.ipv6.assign_ipv6_address_on_creation
  private_subnet_assign_ipv6_address_on_creation = var.ipv6.private_subnet_assign_ipv6_address_on_creation
  public_subnet_assign_ipv6_address_on_creation  = var.ipv6.public_subnet_assign_ipv6_address_on_creation

  public_subnet_ipv6_prefixes  = [0, 1, 2]
  private_subnet_ipv6_prefixes = [3, 4, 5]

  tags = {
    Terraform                                                     = "true"
    Environment                                                   = var.tfenv
    "kubernetes.io/cluster/eks-${var.app_namespace}-${var.tfenv}" = "shared"
    Namespace                                                     = var.app_namespace
    Billingcustomer                                               = var.billingcustomer
    Product                                                       = var.app_name
    infrastructure-eks-terraform                                  = local.module_version
  }

  nat_gateway_tags = {
    Terraform                    = "true"
    "Environment"                = var.tfenv
    Namespace                    = var.app_namespace
    Billingcustomer              = var.billingcustomer
    Product                      = var.app_name
    infrastructure-eks-terraform = local.module_version
  }

  vpc_tags = {
    Name = "eks-${var.app_namespace}-${var.tfenv}-cluster-vpc"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/eks-${var.app_namespace}-${var.tfenv}" = "shared"
    "kubernetes.io/role/elb"                                      = "1"
    "Environment"                                                 = var.tfenv
    Terraform                                                     = "true"
    Namespace                                                     = var.app_namespace
    Billingcustomer                                               = var.billingcustomer
    Product                                                       = var.app_name
    infrastructure-eks-terraform                                  = local.module_version
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/eks-${var.app_namespace}-${var.tfenv}" = "shared"
    "kubernetes.io/role/internal-elb"                             = "1"
    "Environment"                                                 = var.tfenv
    Terraform                                                     = "true"
    Namespace                                                     = var.app_namespace
    Billingcustomer                                               = var.billingcustomer
    Product                                                       = var.app_name
    infrastructure-eks-terraform                                  = local.module_version
  }
}

module "eks-vpc-endpoints" {
  source  = "terraform-aws-modules/vpc/aws/modules/vpc-endpoints"
  version = "~> 3.1"

  vpc_id = module.eks-vpc.vpc_id
  security_group_ids = [
    module.eks.cluster_primary_security_group_id,
    module.eks.cluster_security_group_id,
    module.eks.worker_security_group_id
  ]

  endpoints = {
    s3 = {
      service = "s3"
      tags = {
        "Environment"                  = var.tfenv
        "Terraform"                    = "true"
        "Namespace"                    = var.app_namespace
        "Billingcustomer"              = var.billingcustomer
        "Product"                      = var.app_name
        "infrastructure-eks-terraform" = local.module_version
        "Name"                         = "${var.app_name}-${var.app_namespace}-${var.tfenv}-s3-vpc-endpoint"
      }
    }
  }
}

resource "aws_vpc_endpoint" "rds" {
  lifecycle { ignore_changes = [dns_entry] }
  vpc_id              = module.eks-vpc.vpc_id
  depends_on          = [module.eks-vpc]
  service_name        = "com.amazonaws.${var.aws_region}.rds"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  security_group_ids = [
    module.eks.cluster_primary_security_group_id,
    module.eks.cluster_security_group_id,
    module.eks.worker_security_group_id
  ]

  tags = {
    Name                                                          = "${var.app_name}-${var.app_namespace}-${var.tfenv}-rds-endpoint"
    Terraform                                                     = "true"
    Environment                                                   = var.tfenv
    "kubernetes.io/cluster/eks-${var.app_namespace}-${var.tfenv}" = "shared"
    Namespace                                                     = var.app_namespace
    Billingcustomer                                               = var.billingcustomer
    Product                                                       = var.app_name
    infrastructure-eks-terraform                                  = local.module_version
  }

  subnet_ids = flatten(module.eks-vpc.private_subnets)
}

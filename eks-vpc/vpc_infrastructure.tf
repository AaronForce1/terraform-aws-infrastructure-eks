data "aws_availability_zones" "available_azs" {
  state = "available"
}
data "aws_availability_zones" "available" {}

module "subnet_addrs" {
  source  = "hashicorp/subnets/cidr"
  version = "1.0.0"

  base_cidr_block = local.base_cidr
  networks = [
    {
      name     = "public-1"
      new_bits = var.vpc_subnet_configuration.subnet_bit_interval.public
    },
    {
      name     = "public-2"
      new_bits = var.vpc_subnet_configuration.subnet_bit_interval.public
    },
    {
      name     = "public-3"
      new_bits = var.vpc_subnet_configuration.subnet_bit_interval.public
    },
    {
      name     = "private-1"
      new_bits = var.vpc_subnet_configuration.subnet_bit_interval.private
    },
    {
      name     = "private-2"
      new_bits = var.vpc_subnet_configuration.subnet_bit_interval.private
    },
    {
      name     = "private-3"
      new_bits = var.vpc_subnet_configuration.subnet_bit_interval.private
    },
    {
      name     = "db-1"
      new_bits = var.vpc_subnet_configuration.subnet_bit_interval.database
    },
    {
      name     = "db-2"
      new_bits = var.vpc_subnet_configuration.subnet_bit_interval.database
    },
    {
      name     = "db-3"
      new_bits = var.vpc_subnet_configuration.subnet_bit_interval.database
    },
    {
      name     = "intra-1"
      new_bits = var.vpc_subnet_configuration.subnet_bit_interval.intra
    },
    {
      name     = "intra-2"
      new_bits = var.vpc_subnet_configuration.subnet_bit_interval.intra
    },
    {
      name     = "intra-3"
      new_bits = var.vpc_subnet_configuration.subnet_bit_interval.intra
    },

  ]
}

module "eks-vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.1"

  name = "eks-${var.app_namespace}-${var.tfenv}-cluster-vpc"
  cidr = local.base_cidr
  azs  = data.aws_availability_zones.available_azs.names

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
  database_subnets = [
    module.subnet_addrs.networks[6].cidr_block,
    module.subnet_addrs.networks[7].cidr_block,
    module.subnet_addrs.networks[8].cidr_block,
  ]
  intra_subnets = [
    module.subnet_addrs.networks[9].cidr_block,
    module.subnet_addrs.networks[10].cidr_block,
    module.subnet_addrs.networks[11].cidr_block,
  ]
  intra_dedicated_network_acl = true

  customer_gateways  = var.customer_gateways
  enable_vpn_gateway = var.customer_gateways != {} ? true : false
  # NAT Gateway settings + EIPs
  enable_nat_gateway                 = local.nat_gateway_configuration.enable_nat_gateway
  enable_dns_hostnames               = local.nat_gateway_configuration.enable_dns_hostnames
  single_nat_gateway                 = local.nat_gateway_configuration.single_nat_gateway
  one_nat_gateway_per_az             = local.nat_gateway_configuration.one_nat_gateway_per_az
  reuse_nat_ips                      = local.nat_gateway_configuration.reuse_nat_ips
  external_nat_ip_ids                = local.nat_gateway_configuration.external_nat_ip_ids
  propagate_public_route_tables_vgw  = local.nat_gateway_configuration.propagate_public_route_tables_vgw
  propagate_private_route_tables_vgw = local.nat_gateway_configuration.propagate_private_route_tables_vgw
  manage_default_network_acl         = false

  public_dedicated_network_acl = true
  public_inbound_acl_rules     = var.public_inbound_acl_rules
  public_outbound_acl_rules = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    },
  ]

  private_dedicated_network_acl = true
  private_inbound_acl_rules     = var.private_inbound_acl_rules
  private_outbound_acl_rules = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    }
  ]

  database_dedicated_network_acl = true
  database_inbound_acl_rules     = var.database_inbound_acl_rules
  database_outbound_acl_rules = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 65535
      protocol    = "tcp"
      cidr_block  = local.base_cidr
    }
  ]


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

  tags = merge({
    "kubernetes.io/cluster/${local.name_prefix}" = "shared"
  }, local.base_tags)

  nat_gateway_tags = local.base_tags

  vpc_tags = merge({
    Name = "${local.name_prefix}-vpc"
  }, local.base_tags)

  public_subnet_tags = merge({
    "kubernetes.io/cluster/${local.name_prefix}" = "shared"
    "kubernetes.io/role/elb"                     = "1"
    "SubnetType"                                 = "public"
  }, local.base_tags)

  private_subnet_tags = merge({
    "kubernetes.io/cluster/${local.name_prefix}" = "shared"
    "kubernetes.io/role/internal-elb"            = "1"
    "SubnetType"                                 = "private"
  }, local.base_tags)

  database_subnet_tags = merge({
    "SubnetType" = "db-private"
  }, local.base_tags)
}

module "eks-vpc-endpoints" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "~> 5.1"

  vpc_id = module.eks-vpc.vpc_id
  security_group_ids = [
    module.eks.cluster_primary_security_group_id,
    module.eks.cluster_security_group_id,
    # module.eks.worker_security_group_id
    module.eks.node_security_group_id
  ]

  endpoints = {
    s3 = {
      service = "s3"
      tags = merge({
        "Name" = "${local.name_prefix}-s3-vpc-endpoint"
      }, local.base_tags)
    }
  }
}

resource "aws_vpc_endpoint" "rds" {
  lifecycle { ignore_changes = [dns_entry] }
  vpc_id = module.eks-vpc.vpc_id

  service_name        = "com.amazonaws.${var.aws_region}.rds"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  security_group_ids = [
    module.eks.cluster_primary_security_group_id,
    module.eks.cluster_security_group_id,
    # module.eks.worker_security_group_id
    module.eks.node_security_group_id
  ]

  tags = merge({
    Name                                         = "${local.name_prefix}-rds-endpoint"
    "kubernetes.io/cluster/${local.name_prefix}" = "shared"
  }, local.base_tags)

  subnet_ids = flatten(module.eks-vpc.private_subnets)
}

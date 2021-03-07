// Configure AWS VPC, Subnets, and Routes
data "aws_availability_zones" "available" {
  state = "available"
}

# resource "aws_eip" "nat_gw_elastic_ip" {
#   vpc = true

#   tags = {
#     Name                = "eks_${var.tfenv}-nat-eip"
#     Terraform           = "true",
#     Environment         = "${var.tfenv}"
#     Namespace           = "${var.app_namespace}"
#     billingcustomer     = "${var.billingcustomer}"
#   }
# }

resource "random_integer" "cidr_vpc" {
  min = 64
  max = 128
  keepers = {
    name = "eks-${var.app_namespace}-${var.tfenv}-cluster-vpc"
  }
}

resource "random_integer" "cidr_priv_1" {
  min = 0
  max = 150
  keepers = {
    name = "eks-${var.app_namespace}-${var.tfenv}-cluster-vpc"
  }
}

resource "random_integer" "cidr_priv_2" {
  min = 0
  max = 150
  keepers = {
    name = "eks-${var.app_namespace}-${var.tfenv}-cluster-vpc"
  }
}
resource "random_integer" "cidr_priv_3" {
  min = 0
  max = 150
  keepers = {
    name = "eks-${var.app_namespace}-${var.tfenv}-cluster-vpc"
  }
}
resource "random_integer" "cidr_pub_1" {
  min = 151
  max = 255
  keepers = {
    name = "eks-${var.app_namespace}-${var.tfenv}-cluster-vpc"
  }
}

resource "random_integer" "cidr_pub_2" {
  min = 151
  max = 255
  keepers = {
    name = "eks-${var.app_namespace}-${var.tfenv}-cluster-vpc"
  }
}

resource "random_integer" "cidr_pub_3" {
  min = 151
  max = 255
  keepers = {
    name = "eks-${var.app_namespace}-${var.tfenv}-cluster-vpc"
  }
}
module "eks-vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 2.66"

  name = "eks-${var.app_namespace}-${var.tfenv}-cluster-vpc"
  cidr = "172.${random_integer.cidr_vpc.result}.0.0/16"


  ##TODO: Modularise these arrays: https://gitlab.com/nicosingh/medium-deploy-eks-cluster-using-terraform/-/blob/master/network.tf
  azs = [
    data.aws_availability_zones.available.names[0],
    data.aws_availability_zones.available.names[1],
    data.aws_availability_zones.available.names[2]
  ]
  private_subnets = [
    // "172.10.0.0/21",
    "172.${random_integer.cidr_vpc.result}.${random_integer.cidr_priv_1.result}.0/24",
    "172.${random_integer.cidr_vpc.result}.${random_integer.cidr_priv_2.result}.0/24",
    "172.${random_integer.cidr_vpc.result}.${random_integer.cidr_priv_3.result}.0/24",
    // "172.20.6.0/23"
  ]
  public_subnets = [
    "172.${random_integer.cidr_vpc.result}.${random_integer.cidr_pub_1.result}.0/24",
    "172.${random_integer.cidr_vpc.result}.${random_integer.cidr_pub_2.result}.0/24",
    "172.${random_integer.cidr_vpc.result}.${random_integer.cidr_pub_3.result}.0/24"
  ]

  enable_nat_gateway   = true
  enable_dns_hostnames = true
  #TODO: For DEV - only one nat gateway is probably fine
  single_nat_gateway     = var.tfenv == "prod" ? false : true
  one_nat_gateway_per_az = false
  # reuse_nat_ips                     = true
  # external_nat_ip_ids               = [aws_eip.nat_gw_elastic_ip.id]
  enable_vpn_gateway                = false
  propagate_public_route_tables_vgw = false

  # VPC endpoint for S3
  enable_s3_endpoint = true

  # VPC endpoint for RDS
  # enable_rds_endpoint = true
  # rds_endpoint_private_dns_enabled = true
  # rds_endpoint_security_group_ids = [
  #   module.eks.cluster_primary_security_group_id,
  #   module.eks.cluster_security_group_id,
  #   module.eks.worker_security_group_id
  # ]

  # Default security group - ingress/egress rules cleared to deny all
  manage_default_security_group  = false
  default_security_group_ingress = [{}]
  default_security_group_egress  = [{}]

  # VPC Flow Logs (Cloudwatch log group and IAM role will be created)
  enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true
  flow_log_max_aggregation_interval    = 60

  tags = {
    Terraform                                                     = "true"
    Environment                                                   = var.tfenv
    "kubernetes.io/cluster/eks-${var.app_namespace}-${var.tfenv}" = "shared"
    Namespace                                                     = var.app_namespace
    Billingcustomer                                               = var.billingcustomer
    infrastructure-eks-terraform                                  = data.local_file.infrastructure-terraform-eks-version.content
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
    infrastructure-eks-terraform                                  = data.local_file.infrastructure-terraform-eks-version.content
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/eks-${var.app_namespace}-${var.tfenv}" = "shared"
    "kubernetes.io/role/internal-elb"                             = "1"
    "Environment"                                                 = var.tfenv
    Terraform                                                     = "true"
    Namespace                                                     = var.app_namespace
    Billingcustomer                                               = var.billingcustomer
    infrastructure-eks-terraform                                  = data.local_file.infrastructure-terraform-eks-version.content
  }
}

resource "aws_vpc_endpoint" "rds" {
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
}

## TODO: Create external VPC for Bastion Hosts and Direct Office - AWS Connetions
# module "external-vpc" {
#   source = "terraform-aws-modules/vpc/aws"

#   name = "eks-${var.tfenv}-external-vpc"
#   cidr = "172.22.0.0/16"
#   azs            = [
#                     data.aws_availability_zones.available.names[0], 
#                     data.aws_availability_zones.available.names[1], 
#                     data.aws_availability_zones.available.names[2]
#                    ]
#   private_subnets = [
#                       // "172.22.0.0/21", 
#                       "172.22.0.0/23",
#                       "172.22.2.0/23",
#                       "172.22.4.0/23",
#                       // "172.22.6.0/23"
#                     ]
#   public_subnets = [
#                       // "172.22.100.0/21", 
#                       "172.22.100.0/23",
#                       "172.22.102.0/23",
#                       "172.22.104.0/23",
#                       // "172.22.106.0/23"
#                    ]

#   enable_nat_gateway                = false
#   enable_dns_hostnames              = true
#   enable_vpn_gateway                = false
#   propagate_public_route_tables_vgw = false

#   # VPC endpoint for S3
#   enable_s3_endpoint = false

#   # Default security group - ingress/egress rules cleared to deny all
#   manage_default_security_group  = true
#   default_security_group_ingress = [{}]
#   default_security_group_egress = [{}]

#   # VPC Flow Logs (Cloudwatch log group and IAM role will be created)
#   enable_flow_log                      = true
#   create_flow_log_cloudwatch_log_group = true
#   create_flow_log_cloudwatch_iam_role  = true
#   flow_log_max_aggregation_interval    = 60

#   tags = {
#     Terraform                                       = "true",
#     Environment                                     = "${var.tfenv}"
#     "kubernetes.io/cluster/eks_${var.tfenv}"        = "shared"
#     Namespace                                       = "${var.app_namespace}"
#     billingcustomer                                 = "${var.billingcustomer}"
#   }

#   vpc_tags = {
#    Name = "eks-${var.tfenv}-external-vpc" 
#   }
# }
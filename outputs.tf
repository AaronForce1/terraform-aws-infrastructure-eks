## -----------
## MODULE: EKS
## -----------

// output "kubecfg" {
//   value = module.eks.kubeconfig
// }
output "kubernetes-cluster-certificate-authority-data" {
  value = module.eks.cluster_certificate_authority_data
}

output "kubernetes-cluster-id" {
  value = module.eks.cluster_id
}

output "kubernetes-cluster-endpoint" {
  value = module.eks.cluster_endpoint
}

output "kubernetes-cluster-auth" {
  value     = data.aws_eks_cluster_auth.cluster
  sensitive = true
}

## -----------
## MODULE: VPC
## -----------
output "vpc_id" {
  value = module.eks-vpc.vpc_id
}

output "private_subnet_ids" {
  value = module.eks-vpc.private_subnets
}

output "private_subnets_cidr_blocks" {
  value = {
    ipv4 = module.eks-vpc.private_subnets_cidr_blocks
    ipv6 = module.eks-vpc.private_subnets_ipv6_cidr_blocks
  }
}

output "private_route_table_ids" {
  value = module.eks-vpc.private_route_table_ids
}

output "public_subnet_ids" {
  value = module.eks-vpc.public_subnets
}

output "public_subnets_cidr_blocks" {
  value = {
    ipv4 = module.eks-vpc.public_subnets_cidr_blocks
    ipv6 = module.eks-vpc.public_subnets_ipv6_cidr_blocks
  }
}

## -----------
## MODULE: subnet_addrs
## -----------

output "base_cidr_block" {
  value = module.subnet_addrs.base_cidr_block
}

output "eks_managed_node_groups" {
  value = module.eks.eks_managed_node_groups
}

## -----------
### Region and AWS Profile Checks
## -----------
output "aws_region" {
  value = var.aws_region
}

output "aws_profile" {
  value = var.aws_profile
}

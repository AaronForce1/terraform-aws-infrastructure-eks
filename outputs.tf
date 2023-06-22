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

###
### Check you are using proper region
###
output "aws_region" {
  value = var.aws_region
}

output "aws_profile" {
  value = var.aws_profile
}

output "oidc_url" {
  value = module.eks.cluster_oidc_issuer_url
}

output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}

output "name_prefix" {
  value = local.name_prefix
}

output "eks_infrastructure_kms_arn" {
  value = aws_kms_key.eks.arn
}

output "eks_managed_node_group_roles" {
  value = local.eks_managed_node_group_roles
}

output "base_tags" {
  value = local.base_tags
}

output "route53_hosted_zone_id" {
  value = aws_route53_zone.hosted_zone[*].id
}

output "route53_hosted_zone_arns" {
  value = aws_route53_zone.hosted_zone[*].arn
}

variable "vpc_id" {}
variable "oidc_url" {}
variable "aws_region" {}
variable "app_name" {}
variable "app_namespace" {}
variable "tfenv" {}
variable "base_cidr_block" {}
variable "billingcustomer" {}
variable "node_count" {}
variable "name_prefix" {}
variable "aws_installations" {}
variable "eks_infrastructure_support_buckets" {}
variable "eks_managed_node_group_roles" {}
variable "eks_infrastructure_kms_arn" {}
variable "oidc_provider_arn" {}
variable "tags" {}
variable "thanos_slave_role" {}
variable "eks_slave" {
  default = ""
}
variable "route53_hosted_zone_arn" {
  default = ""
}


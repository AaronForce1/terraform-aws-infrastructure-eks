variable "vpc_id" {}
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
variable "eks_infrastructure_kms_arn" {}
variable "oidc_provider_arn" {}
variable "tags" {}
variable "route53_hosted_zone_arn" {
  default = ""
}
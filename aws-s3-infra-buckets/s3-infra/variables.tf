variable "oidc_url" {}
variable "app_name" {
  default = ""
}
variable "app_namespace" {}
variable "tfenv" {}
variable "name_prefix" {}
variable "eks_infrastructure_support_buckets" {}
variable "eks_managed_node_group_roles" {}
variable "eks_infrastructure_kms_arn" {}
variable "tags" {}
variable "thanos_slave_role" {
  type        = bool
  description = "enable thanos slave role"
  default     = false
}
variable "eks_slave" {
  default = ""
}
variable "route53_hosted_zone_arns" {
  default = []
}
variable "slave_assume_operator_roles" {
  default = ""
}
variable "teleport_bucket" {}


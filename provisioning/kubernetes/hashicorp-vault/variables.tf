variable "aws_region" {}
variable "app_namespace" {}
variable "tfenv" {}
variable "root_domain_name" {}
variable "app_name" {}
variable "enable_aws_vault_unseal" {}
variable "billingcustomer" {}
variable "vault_nodeselector" {}

variable "custom_manifest" {
  default = null
}
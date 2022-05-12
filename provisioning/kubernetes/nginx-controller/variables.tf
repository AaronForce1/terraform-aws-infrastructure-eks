variable "root_domain_name" {}
variable "app_namespace" {}
variable "tfenv" {}

variable "billingcustomer" {}
variable "app_name" {}
variable "infrastructure_eks_terraform_version" {}
variable "custom_manifest" {
  default = null
}
variable "ingress_records" {
  type    = list(string)
  default = []
}
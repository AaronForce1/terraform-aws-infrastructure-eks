variable "app_namespace" {}
variable "tfenv" {}
variable "root_domain_name" {}
variable "app_name" {}
variable "vault_nodeselector" {}
variable "vault_tolerations" {}
variable "tags" {}

variable "custom_manifest" {
  default = null
}
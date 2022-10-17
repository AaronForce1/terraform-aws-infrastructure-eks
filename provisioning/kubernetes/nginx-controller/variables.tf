variable "cluster_root_domain" {
  description = "Domain root where all kubernetes systems are orchestrating control"
}

variable "app_namespace" {
  description = "Tagged App Namespace"
}

variable "tfenv" {
  description = "Environment"
}

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

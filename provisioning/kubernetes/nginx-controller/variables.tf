variable "root_domain_name" {
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
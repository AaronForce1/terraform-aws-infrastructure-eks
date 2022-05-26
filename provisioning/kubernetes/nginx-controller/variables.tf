variable "root_domain_name" {
  description = "Domain root where all kubernetes systems are orchestrating control"
}
variable "app_namespace" {}
variable "tfenv" {}
variable "billingcustomer" {}
variable "app_name" {}
variable "infrastructure_eks_terraform_version" {}
variable "chart_version" {
  default = null
}
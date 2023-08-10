locals {
  name_prefix = "${var.app_name}-${var.app_namespace}-${var.tfenv}"
  base_tags = {
    Product         = var.app_name
    Namespace       = var.app_namespace
    Environment     = var.tfenv
    Billingcustomer = var.billingcustomer
    Terraform       = "true"
  }
}
locals {
  elkversion = var.chart_version != null ? var.chart_version : "v7.16.3"
}

variable "google_clientID" {}
variable "google_clientSecret" {}
variable "google_authDomain" {}

variable "tfenv" {}
variable "app_name" {}
variable "app_namespace" {}
variable "root_domain_name" {}
variable "billingcustomer" {}
variable "aws_region" {}
variable "tags" {}
variable "chart_version" {
  default = null
}

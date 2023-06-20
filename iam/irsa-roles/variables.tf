variable "iam-irsa" {
  type = any
}
variable "app_name" {
  default = ""
}
variable "app_namespace" {
  default = ""
}
variable "tfenv" {
  default = ""
}
variable "route53_hosted_zone_arns" {
  type = any
}
variable "oidc_provider_arn" {
  default = ""
}

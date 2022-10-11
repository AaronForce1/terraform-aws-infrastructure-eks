variable "custom_manifest" {
  default = null
}
variable "root_domain_name" {
  default = ""
}
variable "hosted_zone_id" {
  default = ""
}
variable "operator_domain_name" {
  default = ""
}
variable "slave_domain_name" {
  default = ""
}
variable "repository_secrets" {
  default = []
}
variable "credential_templates" {
  default = []
}
variable "registry_secrets" {
  default = []
}
variable "argocd_google_oauth_template" {
  default = []
}
variable "grafana_google_oauth_template" {
  default = []
}

variable "generate_plugin_repository_secret" {
  default = false
}
variable "additionalProjects" {
  default = []
}
variable "chart_version" {
  default = "4.10.9"
}
variable "kms_key_id" {
  default = ""
}

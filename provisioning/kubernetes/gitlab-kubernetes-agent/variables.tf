variable "app_namespace" {}
variable "tfenv" {}
variable "gitlab_agent_url" {}
variable "gitlab_agent_secret" {}
variable "chart_version" {
  type    = string
  default = "v1.4.0"
}
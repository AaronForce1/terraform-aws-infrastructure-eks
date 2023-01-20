variable "chart_version" {
  type    = string
}

variable "cluster_name" {
  type    = string
}

variable "proxy_address" {
  type = string
}

variable "auth_token" {
  type = string
}

variable "custom_manifest" {
  type    = string
  default = null
}
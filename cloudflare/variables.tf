variable "cloudflare_account_id" {
  type        = string
  description = "Cloudflare Account ID"
}

variable "tunnel_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_network" {
  type = string
}

variable "tunnel_secret_name" {
  type    = string
  default = ""
}

variable "tunnel_secret_namespace" {
  type    = string
  default = ""
}
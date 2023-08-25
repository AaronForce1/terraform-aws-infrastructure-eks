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

variable "eks_cluster_name" {
  type = string
}

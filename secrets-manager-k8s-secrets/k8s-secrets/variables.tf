variable "eks_cluster_name" {
  default = ""
}

variable "secrets" {
  description = "List of maps, each containing 'name', 'namespace', and 'values'"
  type        = any
}

variable "secrets_manager_secret_arn" {
  description = "The ARN of the Secrets Manager secret containing the JSON with multiple secrets."
}

variable "secrets_manager_secret_version_id" {
  description = "The version ID of the Secrets Manager secret."
}

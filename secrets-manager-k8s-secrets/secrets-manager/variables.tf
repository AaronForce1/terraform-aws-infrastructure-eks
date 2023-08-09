variable "secrets" {
  description = "List of maps, each containing 'name', 'namespace', and 'values'"
  type = any
}

variable "secretsmanager_name" {
  default = "my-awesome-secret"
}

variable "kms_key_arn" {
  default = ""
}


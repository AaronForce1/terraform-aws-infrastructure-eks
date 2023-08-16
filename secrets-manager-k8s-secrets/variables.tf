variable "eks_cluster_name" {
  default = ""
}
variable "secrets" {
  type = any
}
variable "secretsmanager_secrets_name" {
  default = "awesome-secret"
}
variable "kms_key_arn" {
  description = "The ARN of the custom KMS key to use for encryption."
  type        = string
}

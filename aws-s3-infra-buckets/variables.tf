variable "oidc_url" {
  type = string
  default = ""
}
variable "app_name" {
  type = string
  default = ""
}
variable "app_namespace" {
  type = string
  default = ""
}
variable "tfenv" {
  type = string
  default = ""
}
variable "name_prefix" {
  type = string
  default = ""
}
variable "eks_infrastructure_support_buckets" {
  ## TODO: Expand capabilities to allow more granular control of node_group access
  description = "Adding the ability to provision additional support infrastructure required for certain EKS Helm chart/App-of-App Components"
  type = list(object({
    name           = string
    bucket_acl     = string
    aws_kms_key_id = optional(string)
    lifecycle_rules = optional(list(object({
      id      = string
      enabled = bool
      filter = object({
        prefix = string
      })
      transition = optional(list(object({
        days          = number
        storage_class = string
      })))
      expiration = object({
        days = number
      })
    })))
    versioning                           = bool
    k8s_namespace_service_account_access = list(string)
    eks_node_group_access                = optional(bool)
  }))
  default = []
}
variable "eks_managed_node_group_roles" {
  type = any
  default = [""]
}
variable "eks_infrastructure_kms_arn" {
  type = string
  default = ""
}
variable "base_tags" {
  type = any
  default = [""]
}
variable "thanos_slave_role" {
  type        = bool
  description = "enable thanos slave role"
  default     = false
}
variable "eks_slave" {
  default = ""
}
variable "slave_assume_operator_roles" {
  description = "Adding the ability to provision additional support infrastructure required for certain EKS Helm chart/App-of-App Components"
  type = list(object({
    name                   = string
    attach_policy_name     = string
    service_account_access = list(string)
    tags                   = map(string)
  }))
  default = []
}
variable "teleport_bucket" {
  default = false
}


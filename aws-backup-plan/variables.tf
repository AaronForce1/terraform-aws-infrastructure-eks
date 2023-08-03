variable "aws_kms_name" {
  description = "The server-side encryption key that is used to protect your backups"
  type        = string
  default     = ""
}

variable "backup_vault" {
  description = "The name of back up vault"
  type = object({
    backup_vault_name = optional(string)
  })
  default = {}
}

variable "backup_vault_lock" {
  description = "Configure vault lock to protect backup vault"
  type = object({
    enabled                       = bool
    vault_lock_max_retention_days = optional(number)
    vault_lock_min_retention_days = optional(number)
  })
  default = {
    enabled = false
  }
}

variable "backup_plan" {
  description = "Configure back up plan"
  type = list(object({
    backup_plan_name      = optional(string)
    rule_name             = optional(string)
    backup_schedule       = optional(string)
    start_window          = optional(number)
    completion_window     = optional(number)
    continuous_backup     = optional(bool) # Available for RDS, S3, and SAP HANA on Amazon EC2 resources.
    backup_retention_days = optional(number)
    backup_resource_name  = optional(list(string))
    exclude_resource_name = optional(list(string))
    selection_tag_name    = optional(string)
    selection_tags = optional(list(object({
      type  = string
      key   = string
      value = string
    })))
  }))
  default = [{}]
}
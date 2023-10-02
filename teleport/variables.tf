## GLOBAL VAR CONFIGURATION
variable "app_name" {
  description = "Application Name"
  type        = string
  default     = "vpn"
}

variable "app_namespace" {
  description = "Tagged App Namespace"
  type        = string
}

variable "tfenv" {
  description = "Environment"
  type        = string
}

variable "billingcustomer" {
  description = "Which Billingcustomer, aka Cost Center, is responsible for this infra provisioning"
  type        = string
}

## TELEPORT VAR CONFIGURATION

variable "teleport_integrations" {
  description = "Configure teleport integration features such as eks auto discovery, rds discovery as well as rds proxy, etc"
  type = object({
    cluster                    = optional(bool)
    cluster_discovery          = optional(bool)
    kube_agent                 = optional(bool)
    rds_discovery              = optional(bool)
    rds_proxy_discovery        = optional(bool)
    agent_service_account_name = optional(string)
    discovered_account         = optional(string)
  })
  default = {
    cluster                    = false
    cluster_discovery          = false
    kube_agent                 = false
    rds_discovery              = false
    rds_proxy_discovery        = false
    discovered_account         = ""
    agent_service_account_name = "teleport-kube-agent"
  }
}
variable "existing_role" {
  default = true
}

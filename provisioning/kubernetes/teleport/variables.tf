variable "teleport_installations" {
  type = list(object({
    chart_name    = string
    chart_version = string
    values_file   = string
  }))
  default = []
}

variable "teleport_integrations" {
  type = object({
    cluster           = bool
    cluster_discovery = bool
    kubernetes_access_control = bool
  })
  default = {
    cluster           = false
    cluster_discovery = false
    kubernetes_access_control = false
  }
}

variable "kubernetes_access_controls" {
  type = list(object({
    value_file = string
  }))
  default = []
}
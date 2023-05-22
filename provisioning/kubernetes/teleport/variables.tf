variable "teleport_installations" {
  type = list(object({
    chart_name = string
    chart_version = string
    values_file = string
  }))
  default = []
}

variable "teleport_integrations" {
  type = object({
    cluster = bool
    cluster_discovery = bool
  })
  default = {
    cluster = false
    cluster_discovery = false
  }
}
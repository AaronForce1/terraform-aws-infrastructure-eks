variable "teleport_installations" {
  type = list(object({
    chart_name = string
    chart_version = string
    values_file = string
  }))
  default = []
}
variable "image_url" {
  type    = string
  default = "twingate/connector"
}

variable "name" {
  type = string
}

variable "logLevel" {
  type    = string
  default = "error"
}

variable "url" {
  type    = string
  default = "twingate.com"
}

variable "group" {
  type = string
}

variable "network_name" {
  type = string
}

variable "cluster_endpoint" {
  type = string
}

variable "additional_resources" {
  type = list(object({
    name    = string
    address = string
    protocols = object({
      allow_icmp = bool
      tcp = object({
        policy = string
        ports  = list(string)
      })
      udp = object({
        policy = string
        ports  = list(string)
      })
    })
  }))
  default = []
}

variable "connector_count" {
  type    = number
  default = 2
}

variable "chart_version" {
  type    = string
  default = "0.1.13"
}

variable "custom_manifest" {
  type    = string
  default = null
}
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

variable "network_name" {
  type = string
}

variable "cluster_endpoint" {
  type = string
}

variable "dns_server" {
  type = string
  default = "8.8.8.8"
}

variable "management_group_configurations" {
  type = list(object({
    name   = string
    create = bool
  }))
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
    group_configurations = list(object({
      name   = string
      create = bool
    }))
  }))
  default = []
}

## TODO: Merge legacy_resource_list with additional_resources and leverage yaml definitions file or custom
## Perhaps convert twingate into a custom helm chart?
variable "legacy_resource_list" {
  type = object({
    address_list = list(object({
      name    = optional(string)
      address = string
    }))
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
    group_configurations = list(object({
      name   = string
      create = bool
    }))
  })
  default = {
    address_list : []
    protocols : {
      allow_icmp : false
      tcp : {
        policy : "DENY_ALL"
        ports : []
      }
      udp : {
        policy : "DENY_ALL"
        ports : []
      }
    }
    group_configurations : []
  }
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
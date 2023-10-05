variable "zone_id" {
  type    = string
  default = ""
}

variable "zone_domain" {
  type    = string
  default = ""
}

variable "custom_rules" {
  type    = list(object({
    action      = string
    expression  = string
    description = string
    enabled     = bool
  }))
  default = []
}

variable "access_rules" {
  type = list(object({
    notes   = string
    mode    = string
    target  = string
    value   = string
  }))
  default = []
}



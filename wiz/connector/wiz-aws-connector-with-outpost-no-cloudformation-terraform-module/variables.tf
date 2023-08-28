variable "external-id" {
  type = string
}

variable "wiz_access_rolename" {
  type    = string
  default = "WizAccess-Role"
}

variable "wiz_scanner_rolename" {
  type    = string
  default = "WizScanner-Role"
}

variable "remote-arn" {
  type    = string
  default = "arn:aws:iam::197171649850:root"
}

variable "outpost-remote-arn" {
  type    = string
  default = "arn:aws:iam::<OUTPOSTACCOUNTID>:root"
}

variable "data-scanning" {
  type    = bool
  default = false
}

variable "tags" {
  default = {}
}

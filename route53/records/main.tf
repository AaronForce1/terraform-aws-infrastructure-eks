variable "records" {
  type = any
}

variable "zone_name" {
  default = ""
}

module "route53_zones" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "2.10.2"

  zone_name = var.zone_name
  records_jsonencoded   = jsonencode([var.records])
}

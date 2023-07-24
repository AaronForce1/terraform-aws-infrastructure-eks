variable "zones" {
  type = any
}
module "route53_zones" {
  source  = "terraform-aws-modules/route53/aws//modules/zones"
  version = "2.10.2"

  zones = var.zones

}

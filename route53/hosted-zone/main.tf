variable "zones" {
  type = any
}
module "route53_zones" {
  source  = "terraform-aws-modules/route53/aws//modules/zones"
  version = "2.10.2"

  zones = var.zones

}

output "route53_zone_zone_id" {
  description = "Zone ID of Route53 zone"
  value       = module.route53_zones.route53_zone_zone_id
}

output "route53_zone_ns" {
  value = module.route53_zones.route53_zone_name_servers
}

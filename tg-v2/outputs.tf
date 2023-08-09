output "tgw_id" {
  value = module.tgw.ec2_transit_gateway_id
}
output "tgw_owner_id" {
  value = module.tgw.ec2_transit_gateway_owner_id
}
output "tgw_arn" {
  value = module.tgw.ec2_transit_gateway_arn
}
output "ram_resource_share_id" {
  value = module.tgw.ram_resource_share_id
}
output "ram_principal_association_id" {
  value = module.tgw.ram_principal_association_id
}
output "attachment_ids" {
  value = module.tgw.ec2_transit_gateway_vpc_attachment_ids
}
output "id" {
  value = local.vpc_attachments
}
output "attachment_id" {
  value = module.tgw.ec2_transit_gateway_vpc_attachment_ids
}
output "route_table_ids" {
  value = module.tgw.tgw_route_table_ids
}


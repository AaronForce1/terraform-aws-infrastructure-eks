
module "vpn-gateway" {
  source  = "terraform-aws-modules/vpn-gateway/aws"
  version = "3.6.0"

  connect_to_transit_gateway                = true
  transit_gateway_id                        = lookup(var.vpn_gateway, "transit_gateway_id", "tgw-02fdc75f3ad80200b")
  customer_gateway_id                       = lookup(var.vpn_gateway, "customer_gateway_id", "")
  remote_ipv4_network_cidr                  = lookup(var.vpn_gateway, "remote_ipv4_network_cidr", "0.0.0.0/0")
  local_ipv4_network_cidr                   = lookup(var.vpn_gateway, "local_ipv4_network_cidr", "0.0.0.0/0")
  vpn_connection_static_routes_only         = true
  vpn_connection_static_routes_destinations = lookup(var.vpn_gateway, "vpn_connection_static_routes_destinations", [lookup(var.vpn_gateway, "local_ipv4_network_cidr", "0.0.0.0/0")])
}

#resource "aws_ec2_transit_gateway_route" "vpn" {
#  for_each = {
#    for k, v in lookup(var.vpn_gateway, "vpn_attachments", {}) : k => v
#  }
#
#  destination_cidr_block = lookup(var.vpn_gateway, "local_ipv4_network_cidr", "0.0.0.0/0")
#  blackhole              = null
#
#  transit_gateway_route_table_id = each.value.transit_gateway_route_table_id
#  transit_gateway_attachment_id  = module.vpn-gateway.vpn_connection_transit_gateway_attachment_id
#}

resource "aws_ec2_transit_gateway_route_table_propagation" "vpn" {
  for_each = {
    for k, v in lookup(var.vpn_gateway, "vpn_attachments", {}) : k => v
  }

  transit_gateway_attachment_id  = module.vpn-gateway.vpn_connection_transit_gateway_attachment_id
  transit_gateway_route_table_id = each.value.transit_gateway_route_table_id
}

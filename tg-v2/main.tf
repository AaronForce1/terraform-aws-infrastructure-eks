
variable "region" {
  default = ""
}

locals {
  peer_profile                          = var.peer_profile
  create_tgw                            = lookup(var.tgw, "create_tgw", false)
  share_tgw                             = lookup(var.tgw, "share_tgw", false)
  name                                  = lookup(var.tgw, "name", "ex-tgw-${replace(basename(path.cwd), "_", "-")}")
  description                           = lookup(var.tgw, "description", "Hextrust TGW shared with several peered AWS accounts")
  amazon_side_asn                       = 64532
  enable_auto_accept_shared_attachments = lookup(var.tgw, "enable_auto_accept_shared_attachments", true)
  ram_resource_share_arn                = lookup(var.tgw, "ram_resource_share_arn", "")
  vpc_attachments                       = lookup(var.tgw, "vpc_attachments", {})
  ram_allow_external_principals         = lookup(var.tgw, "ram_allow_external_principals", false)
  ram_principals                        = lookup(var.tgw, "ram_principals", [])
  tgw_default_route_table_tags          = lookup(var.tgw, "tgw_default_route_table_tags", {})
  transit_gateway_id                    = lookup(var.tgw, "transit_gateway_id", "")
  tags = {
    Name      = local.name
    Component = "Network/Security"
  }
  transit_gateway_route_table_id = lookup(var.tgw, "transit_gateway_route_table_id", null)
  customer_gateways              = lookup(var.tgw, "customer_gateways", {})
  create_cgw                     = lookup(var.tgw, "create_cgw", false)
}

################################################################################
# Transit Gateway Module
################################################################################


variable "tgw" {
  type = any
}
variable "peer_profile" {
  type    = string
  default = "test"
}
module "tgw" {
  source = "./module"

  peer_profile                          = local.peer_profile
  create_tgw                            = local.create_tgw
  share_tgw                             = local.share_tgw
  name                                  = local.name
  description                           = local.description
  amazon_side_asn                       = local.amazon_side_asn
  enable_auto_accept_shared_attachments = local.enable_auto_accept_shared_attachments
  ram_resource_share_arn                = local.ram_resource_share_arn
  vpc_attachments                       = local.vpc_attachments
  ram_allow_external_principals         = local.ram_allow_external_principals
  ram_principals                        = local.ram_principals
  transit_gateway_id                    = local.transit_gateway_id
  tags                                  = local.tags
  create_cgw                            = local.create_cgw
  customer_gateways                     = local.customer_gateways
}

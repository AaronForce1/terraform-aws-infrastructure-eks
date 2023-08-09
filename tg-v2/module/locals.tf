locals {
  # List of maps with key and route values
  vpc_attachments_with_routes = chunklist(flatten([
    for k, v in var.vpc_attachments : setproduct([{ key = k }], v.tgw_routes) if can(v.tgw_routes)
  ]), 2)

  tgw_default_route_table_tags_merged = merge(
    var.tags,
    { Name = var.name },
    var.tgw_default_route_table_tags,
  )

  vpc_route_table_destination_cidr = flatten([
    for k, v in var.vpc_attachments : [
      for rtb_id in try(v.vpc_route_table_ids, []) : {
        rtb_id = rtb_id
        cidr   = v.tgw_destination_cidr
      }
    ]
  ])
}

locals {
  all_routes = flatten([
    for vpc, attachments in var.vpc_attachments :
    [
      for rtb_id in try(attachments.vpc_route_table_ids, []) :
      [
        for cidr in try(attachments.tgw_destination_cidr, []) : {
          key                    = "${vpc}-${rtb_id}-${cidr}"
          route_table_id         = rtb_id
          destination_cidr_block = cidr
          transit_gateway_id     = var.create_tgw == true ? aws_ec2_transit_gateway.this[0].id : var.transit_gateway_id
        }
      ]
    ]
  ])
}

locals {
  valid_vpc_attachments = flatten([
    for key, value in var.vpc_attachments :
    can(value.additional_transit_gateway_attachment_ids) ? [for attachment_id in value.additional_transit_gateway_attachment_ids :
      {
        key                            = key
        transit_gateway_attachment_id  = attachment_id
        transit_gateway_route_table_id = value.tgw_id
    }] : []
  ])
}

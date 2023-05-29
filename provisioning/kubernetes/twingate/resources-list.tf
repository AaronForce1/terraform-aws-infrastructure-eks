resource "twingate_resource" "additional_resources_list" {
  for_each = {
    for resource in try(var.legacy_resource_list.address_list, []) : "resource-${coalesce(resource.name, resource.address)}" => resource
  }

  name              = coalesce(each.value.name, each.value.address)
  address           = each.value.address
  remote_network_id = twingate_remote_network.aws_network.id
  group_ids = concat(
    [for group in local.resource_group_creation : twingate_group.additional_resources_created_groups[group.name].id if group.parent == coalesce(each.value.name, each.value.address)],
    flatten([for group in var.legacy_resource_list.group_configurations : [
      for block in data.twingate_groups.additional_resources_existing_groups[group.name].groups :
      block.id
      ]
      if !group.create
    ])
    # Adding distinct flatten to transform from [["foo"],["bar"]] to ["foo","bar"]
    # distinct(flatten([for group in local.resource_group_existing: 
    #  [
    #   for block in data.twingate_groups.additional_resources_existing_groups["${coalesce(each.value.name, each.value.address)}-${group.name}"].groups:
    #     block.id
    #  ]
    #   if can(data.twingate_groups.additional_resources_existing_groups["${coalesce(each.value.name, each.value.address)}-${group.name}"])
    # ]))
  )
  protocols {
    allow_icmp = var.legacy_resource_list.protocols.allow_icmp
    tcp {
      policy = var.legacy_resource_list.protocols.tcp.policy
      ports  = var.legacy_resource_list.protocols.tcp.ports
    }
    udp {
      policy = var.legacy_resource_list.protocols.udp.policy
      ports  = var.legacy_resource_list.protocols.udp.ports
    }
  }
}
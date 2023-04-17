resource "twingate_resource" "additional_resources" {
  for_each = {
    for resource in coalesce(var.additional_resources, []) : "resource-${resource.name}" => resource
    # if resource.address != null
  }

  name              = "cluster-resource-${each.value.name}"
  address           = each.value.address
  remote_network_id = twingate_remote_network.aws_network.id
  group_ids         = concat(
    [for group in local.resource_group_creation: twingate_group.additional_resources_created_groups[group.name].id if group.parent == each.value.name],
    flatten([for group in each.value.group_configurations: [
      for block in data.twingate_groups.additional_resources_existing_groups[group.name].groups: 
        block.id
      ] 
      if !group.create
    ])
    
    # Adding distinct flatten to transform from [["foo"],["bar"]] to ["foo","bar"]
    # distinct(flatten([for group in local.resource_group_existing: 
    #  [
    #   for block in data.twingate_groups.additional_resources_existing_groups["${each.value.name}-${group.name}"].groups:
    #     block.id
    #  ]
    #   if can(data.twingate_groups.additional_resources_existing_groups["${each.value.name}-${group.name}"])
    # ]))
  )
  protocols {
    allow_icmp = each.value.protocols.allow_icmp
    tcp {
      policy = each.value.protocols.tcp.policy
      ports  = each.value.protocols.tcp.ports
    }
    udp {
      policy = each.value.protocols.udp.policy
      ports  = each.value.protocols.udp.ports
    }
  }
}
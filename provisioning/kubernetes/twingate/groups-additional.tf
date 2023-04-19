locals {
  ## TODO: RESOURCE GROUP CREATION STILL V1 AS THERE MAY BE DIFFERENT VERSIONS BEING USED - TBC.
  resource_group_creation_v2 = distinct(flatten([
    for resource in var.additional_resources: [
      for group in resource.group_configurations: group.name
      if group.create
    ]
  ]))
  resource_group_existing_v2 = distinct(flatten([
    for resource in var.additional_resources: [
      for group in concat(resource.group_configurations, var.legacy_resource_list.group_configurations): group.name
      if !group.create
    ]
  ]))
}

locals {
  resource_group_creation = concat(
    distinct(flatten([
      for resource in var.additional_resources: [
        for group in resource.group_configurations: {
          name = group.name
          parent = resource.name
        }
        if group.create
      ]
    ])),
    distinct(flatten([
      for resource in try(var.legacy_resource_list.address_list, []) : [
        for group in var.legacy_resource_list.group_configurations: {
          name = group.name
          parent = coalesce(resource.name, resource.address)
        }
        if group.create
      ]
    ]))
  )
## TODO: DEPRECATING FOR V2
  resource_group_existing = concat(
    distinct(flatten([
      for resource in var.additional_resources: [
        for group in resource.group_configurations: {
          name = group.name
          parent = resource.name
        }
        if !group.create
      ]
    ])),
    distinct(flatten([
      for resource in try(var.legacy_resource_list.address_list, []) : [
        for group in var.legacy_resource_list.group_configurations: {
          name = group.name
          parent = coalesce(resource.name, resource.address)
        }
        if !group.create
      ]
    ]))
  )
}
resource "twingate_group" "additional_resources_created_groups" {
  # for_each = {
  #   for group in distinct(local.resource_group_configs) : "${group.parent}-${group.name}" => group 
  #   if group.create
  # }
  # for_each = {
  #   for resource in var.additional_resources: resource.name => {
  #     for i, group in resource.group_configurations: group.name => group
  #     if group.create
  #   }
  # }
  for_each = {
    for item in local.resource_group_creation: item.name => item
  }

  name = each.value.name
}

data "twingate_groups" "additional_resources_existing_groups" {
  # for_each = {
  #   for group in distinct(local.resource_group_configs) : "${group.parent}-${group.name}" => group
  #   if !group.create
  # }
  for_each = {
    for item in local.resource_group_existing_v2: item => item
  }

  name = each.value
  is_active = true
}
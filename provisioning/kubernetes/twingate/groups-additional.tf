locals {
  resource_group_creation = distinct(flatten([
    for resource in var.additional_resources: [
      for group in resource.group_configurations: {
        name = group.name
        parent = resource.name
      }
      if group.create
    ]
  ]))

  resource_group_existing = distinct(flatten([
    for resource in var.additional_resources: [
      for group in resource.group_configurations: {
        name = group.name
        parent = resource.name
      }
      if !group.create
    ]
  ]))
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
    for item in local.resource_group_existing: "${item.parent}-${item.name}" => item
  }

  name = each.value.name
  is_active = true
}
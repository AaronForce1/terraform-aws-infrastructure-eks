locals {
  management_group_assignment = concat(
    flatten([
      for manager in var.management_group_configurations : [
        for group in data.twingate_groups.management_existing_groups[manager.name].groups : group.id
      ]
      if !manager.create
    ]),
    flatten([
      for manager in var.management_group_configurations : [
        for group in twingate_group.management_created_groups : group.id
      ]
      if manager.create
    ])
  )
}

resource "twingate_group" "management_created_groups" {
  for_each = {
    for group in var.management_group_configurations : group.name => group
    if group.create
  }

  name = each.value.name
}

data "twingate_groups" "management_existing_groups" {
  for_each = {
    for group in var.management_group_configurations : group.name => group
    if !group.create
  }

  name      = each.value.name
  is_active = true
}

# resource "twingate_group" "additional_resources_created_groups" {
#   for_each = {
#     for group in local.resource_group_configs : "${group.parent}-${group.name}" => group 
#     if group.create
#   }

#   name = each.value.name
# }

# data "twingate_groups" "additional_resources_existing_groups" {
#   for_each = {
#     for group in local.resource_group_configs : "${group.parent}-${group.name}" => group
#     if !group.create
#   }

#   name = each.value.name
#   is_active = true
# }
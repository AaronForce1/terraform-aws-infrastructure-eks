resource "twingate_remote_network" "aws_network" {
  name     = var.name
  location = "AWS"
}

# resource "random_pet" "connector_name" {
#   count = var.connector_count
# }

resource "twingate_connector" "aws_connector" {
  count = var.connector_count

  remote_network_id = twingate_remote_network.aws_network.id
  # name = each.key
}

resource "twingate_connector_tokens" "aws_connector_tokens" {
  count = var.connector_count

  connector_id = twingate_connector.aws_connector[count.index].id
}

resource "twingate_resource" "cluster_endpoint" {
  name              = "eks-cluster-endpoint"
  address           = var.cluster_endpoint
  remote_network_id = twingate_remote_network.aws_network.id
  group_ids         = local.management_group_assignment
  protocols {
    allow_icmp = false
    tcp {
      policy = "RESTRICTED"
      ports  = ["443"]
    }
    udp {
      policy = "DENY_ALL"
    }
  }
}

resource "twingate_resource" "additional_resources" {
  for_each = {
    for resource in coalesce(var.additional_resources, []) : "resource-${resource.name}" => resource
  }

  name              = "cluster-resource-${each.value.name}"
  address           = each.value.address
  remote_network_id = twingate_remote_network.aws_network.id
  group_ids         = concat(
    [for group in local.resource_group_creation: twingate_group.additional_resources_created_groups[group.name].id if group.parent == each.value.name],
    # Adding distinct flatten to transform from [["foo"],["bar"]] to ["foo","bar"]
    distinct(flatten([for group in local.resource_group_existing: 
     [
      for block in data.twingate_groups.additional_resources_existing_groups["${each.value.name}-${group.name}"].groups:
        block.id
     ]
      if can(data.twingate_groups.additional_resources_existing_groups["${each.value.name}-${group.name}"])
    ]))
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
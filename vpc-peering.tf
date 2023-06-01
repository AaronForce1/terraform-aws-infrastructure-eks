# Peering 
resource "aws_vpc_peering_connection" "vpc_peering" {
  for_each = {
    for vpc in var.vpc_peering : vpc.peer_vpc_id => vpc
  }

  peer_owner_id = try(
    each.value.peer_owner_same_aws_acc == true ?
    data.aws_caller_identity.current.account_id :
    each.value.peer_owner_aws_acc_id
  )
  peer_vpc_id = each.value.peer_vpc_id
  vpc_id      = module.eks-vpc.vpc_id
  peer_region = each.value.peer_region
}

# Get vpc info
# data "aws_vpc" "vpc_peering" {
#     for_each = {
#         for vpc in var.vpc_peering : vpc.peer_vpc_id => vpc
#         if vpc.add_to_routetable
#     }

#     id = each.key
# }

# Combines vpc_peering and route table ids
locals {
  vpc_peering_routes = toset(distinct(flatten([
    for vpc in var.vpc_peering : [
      for route_table_id in module.eks-vpc.private_route_table_ids : {
        vpc            = vpc
        route_table_id = route_table_id
      }
    ]
  ])))
}

# output "peering" {
#     value = local.vpc_peering_routes
# }

# route table route
resource "aws_route" "vpc_peering" {
  for_each = {
    for vpc_route in local.vpc_peering_routes :
    format("%s/%s", vpc_route.vpc.peer_vpc_id, vpc_route.route_table_id) => vpc_route
    if vpc_route.vpc.add_to_routetable
  }

  route_table_id            = each.value.route_table_id
  destination_cidr_block    = each.value.vpc.peer_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering[each.value.vpc.peer_vpc_id].id
  depends_on = [
    aws_vpc_peering_connection.vpc_peering
  ]
}
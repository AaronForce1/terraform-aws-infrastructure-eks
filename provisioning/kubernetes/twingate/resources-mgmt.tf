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
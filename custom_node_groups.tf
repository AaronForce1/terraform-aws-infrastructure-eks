resource "aws_eks_node_group" "custom_node_group" {
  lifecycle { ignore_changes = [ scaling_config.desired_size ] }
  count = length(var.managed_node_groups)

  cluster_name    = "${var.app_name}-${var.app_namespace}-${var.tfenv}"
  node_group_name = var.managed_node_groups[count.index].name
  node_role_arn   = module.eks.worker_iam_role_arn
  subnet_ids = concat(
    var.managed_node_groups[count.index].subnet_selections.public ? module.eks-vpc.public_subnets : [],
    var.managed_node_groups[count.index].subnet_selections.private ? module.eks-vpc.private_subnets : []
  )

  scaling_config {
    desired_size = var.managed_node_groups[count.index].desired_capacity
    max_size     = var.managed_node_groups[count.index].max_capacity
    min_size     = var.managed_node_groups[count.index].min_capacity
  }

  disk_size      = var.managed_node_groups[count.index].disk_size
  instance_types = [var.managed_node_groups[count.index].instance_type]
  ami_type       = var.managed_node_groups[count.index].ami_type != null ? var.managed_node_groups[count.index].ami_type : var.default_ami_type

  labels = merge(
    { Environment = var.tfenv },
    zipmap(
      [
        for x in var.managed_node_groups[count.index].taints : x.key
        if x.affinity_label
      ],
      [
        for x in var.managed_node_groups[count.index].taints : x.value
        if x.affinity_label
      ]
    )
  )
  tags = local.kubernetes_tags
  dynamic "taint" {
    for_each = var.managed_node_groups[count.index].taints
    content {
      key    = taint.value["key"]
      value  = taint.value["value"]
      effect = taint.value["effect"]
    }
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    module.eks-vpc, module.eks
  ]
}

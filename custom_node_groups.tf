resource "aws_eks_node_group" "custom_node_group" {
  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    module.eks
  ]

  count = length(var.eks_managed_node_groups)

  cluster_name    = "${var.app_name}-${var.app_namespace}-${var.tfenv}"
  node_group_name = var.eks_managed_node_groups[count.index].name
  node_role_arn   = module.eks.worker_iam_role_arn
  subnet_ids = concat(
    var.eks_managed_node_groups[count.index].subnet_selections.public ? module.eks-vpc.public_subnets : [],
    var.eks_managed_node_groups[count.index].subnet_selections.private ? module.eks-vpc.private_subnets : []
  )

  scaling_config {
    desired_size = var.eks_managed_node_groups[count.index].desired_capacity
    max_size     = var.eks_managed_node_groups[count.index].max_capacity
    min_size     = var.eks_managed_node_groups[count.index].min_capacity
  }

  disk_size = var.eks_managed_node_groups[count.index].disk_size
  # disk_encrypted = var.eks_managed_node_groups[count.index].disk_encrypted != null ? var.eks_managed_node_groups[count.index].disk_encrypted : true
  instance_types = var.eks_managed_node_groups[count.index].instance_types
  ami_type       = var.eks_managed_node_groups[count.index].ami_type != null ? var.eks_managed_node_groups[count.index].ami_type : var.default_ami_type

  capacity_type = var.eks_managed_node_groups[count.index].capacity_type != null ? var.eks_managed_node_groups[count.index].capacity_type : var.default_capacity_type

  labels = merge(
    { Environment = var.tfenv },
    zipmap(
      [
        for x in var.eks_managed_node_groups[count.index].taints : x.key
        if x.affinity_label
      ],
      [
        for x in var.eks_managed_node_groups[count.index].taints : x.value
        if x.affinity_label
      ]
    )
  )
  tags = merge(
    local.kubernetes_tags,
    { "Name" : var.eks_managed_node_groups[count.index].name }
    # var.eks_managed_node_groups[count.index].tags != null ? var.eks_managed_node_groups[count.index].tags : []
  )
  dynamic "taint" {
    for_each = var.eks_managed_node_groups[count.index].taints
    content {
      key    = taint.value["key"]
      value  = taint.value["value"]
      effect = taint.value["effect"]
    }
  }
}

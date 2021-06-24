resource "aws_eks_node_group" "custom_node_groip" {
  count = length(var.managed_node_groups)

  cluster_name    = "${var.app_name}-${var.app_namespace}-${var.tfenv}"
  node_group_name = var.managed_node_groups[count.index].name
  node_role_arn   = module.eks.worker_iam_role_arn
  subnet_ids      = concat(
    var.managed_node_groups[count.index].subnet_selections.public ? module.eks-vpc.public_subnets : [],
    var.managed_node_groups[count.index].subnet_selections.private ? module.eks-vpc.private_subnets : []
  )

  scaling_config {
    desired_size = var.managed_node_groups[count.index].desired_capacity
    max_size     = var.managed_node_groups[count.index].max_capacity
    min_size     = var.managed_node_groups[count.index].min_capacity
  }

  disk_size = var.managed_node_groups[count.index].disk_size
  instance_types = [var.managed_node_groups[count.index].instance_type]

  labels = {
    Environment = var.tfenv
  }
  tags = concat(local.kubernetes_tags, local.additional_kubernetes_tags)
  taint = var.managed_node_groups[count.index].taints

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.example-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.example-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.example-AmazonEC2ContainerRegistryReadOnly,
  ]
}
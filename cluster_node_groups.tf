module "eks_managed_node_group" {
  source  = "terraform-aws-modules/eks/aws//modules/eks-managed-node-group"
  version = "~> 18.23.0"

  count = length(var.eks_managed_node_groups)

  name            = var.eks_managed_node_groups[count.index].name
  use_name_prefix = false
  cluster_name    = module.eks.cluster_id
  cluster_version = var.cluster_version

  create_iam_role                 = true
  launch_template_name            = "${module.eks.cluster_id}-${var.eks_managed_node_groups[count.index].name}"
  launch_template_use_name_prefix = false
  # iam_role_arn = module.eks.eks_managed_node_groups.iam_role.arn

  # cluster_ip_family = "ipv6" # NOT READY
  vpc_id = module.eks-vpc.vpc_id
  subnet_ids = concat(
    var.eks_managed_node_groups[count.index].subnet_selections.public ? module.eks-vpc.public_subnets : [],
    var.eks_managed_node_groups[count.index].subnet_selections.private ? module.eks-vpc.private_subnets : []
  )
  cluster_primary_security_group_id = module.eks.cluster_primary_security_group_id
  vpc_security_group_ids            = [module.eks.node_security_group_id]
  create_security_group             = false

  desired_size = var.eks_managed_node_groups[count.index].desired_capacity
  max_size     = var.eks_managed_node_groups[count.index].max_capacity
  min_size     = var.eks_managed_node_groups[count.index].min_capacity

  instance_types = var.eks_managed_node_groups[count.index].instance_types
  ami_type       = var.eks_managed_node_groups[count.index].ami_type != null ? var.eks_managed_node_groups[count.index].ami_type : var.default_ami_type
  capacity_type  = var.eks_managed_node_groups[count.index].capacity_type != null ? var.eks_managed_node_groups[count.index].capacity_type : var.default_capacity_type

  disk_size     = var.eks_managed_node_groups[count.index].disk_size
  ebs_optimized = true

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

  taints = {
    for taint in var.eks_managed_node_groups[count.index].taints : taint.key => {
      key            = taint.key
      value          = taint.value
      effect         = taint.effect
      affinity_label = taint.affinity_label
    }
  }

  tags = merge(
    local.kubernetes_tags,
    { "Name" : var.eks_managed_node_groups[count.index].name }
    # var.eks_managed_node_groups[count.index][count.index].tags != null ? var.eks_managed_node_groups[count.index][count.index].tags : []
  )
}
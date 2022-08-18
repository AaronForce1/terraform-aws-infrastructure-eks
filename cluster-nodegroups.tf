module "eks_managed_node_group" {
  source  = "terraform-aws-modules/eks/aws//modules/eks-managed-node-group"
  version = "~> 18.23.0"

  for_each = {
    for node_group in var.eks_managed_node_groups : node_group.name => node_group
  }

  name            = each.value.name
  use_name_prefix = false
  cluster_name    = module.eks.cluster_id
  cluster_version = var.cluster_version

  create_iam_role            = true
  iam_role_name              = "${module.eks.cluster_id}-${each.value.name}"
  iam_role_attach_cni_policy = true
  iam_role_use_name_prefix   = false

  launch_template_name            = "${module.eks.cluster_id}-${each.value.name}"
  launch_template_use_name_prefix = false
  # iam_role_arn = module.eks.eks_managed_node_groups.iam_role.arn

  # cluster_ip_family = "ipv6" # NOT READY
  vpc_id = module.eks-vpc.vpc_id
  subnet_ids = concat(
    each.value.subnet_selections.public ? module.eks-vpc.public_subnets : [],
    each.value.subnet_selections.private ? module.eks-vpc.private_subnets : []
  )
  cluster_primary_security_group_id = module.eks.cluster_primary_security_group_id
  # vpc_security_group_ids            = [module.eks.node_security_group_id]
  create_security_group = false

  desired_size = each.value.desired_capacity
  max_size     = each.value.max_capacity
  min_size     = each.value.min_capacity

  instance_types = each.value.instance_types
  ami_type       = each.value.ami_type != null ? each.value.ami_type : var.default_ami_type
  capacity_type  = each.value.capacity_type != null ? each.value.capacity_type : var.default_capacity_type

  disk_size     = each.value.disk_size
  ebs_optimized = true

  labels = merge(
    { Environment = var.tfenv },
    zipmap(
      [
        for x in each.value.taints : x.key
        if x.affinity_label
      ],
      [
        for x in each.value.taints : x.value
        if x.affinity_label
      ]
    )
  )

  taints = {
    for taint in each.value.taints : taint.key => {
      key            = taint.key
      value          = taint.value
      effect         = taint.effect
      affinity_label = taint.affinity_label
    }
  }

  tags = merge(
    local.kubernetes_tags,
    { "Name" : each.value.name }
    # each.value[count.index].tags != null ? each.value[count.index].tags : []
  )
}
variable "base_tags" {
  default = ""
}
module "karpenter" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "19.15.3"

  cluster_name                    = var.karpenter.cluster_name #module.eks.cluster_name
  irsa_name                       = "karpenter-irsa-${var.karpenter.cluster_name}"
  iam_role_name                   = "karpenter-role-${var.karpenter.cluster_name}"
  irsa_use_name_prefix            = false
  iam_role_use_name_prefix        = false
  irsa_oidc_provider_arn          = var.karpenter.irsa_oidc_provider_arn # module.eks.oidc_provider_arn
  irsa_namespace_service_accounts = ["karpenter:karpenter"]
  tags                            = var.karpenter.base_tags
  irsa_tag_key                    = "karpenter.sh/managed-by"
  irsa_tag_values                 = lookup(var.karpenter, "irsa_tag_values", [var.karpenter.cluster_name])
}

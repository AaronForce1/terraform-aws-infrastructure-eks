variable "base_tags" {
  default = ""
}
module "karpenter" {
  source = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "19.15.3"

  cluster_name = var.karpenter.cluster_name #module.eks.cluster_name
  irsa_oidc_provider_arn          = var.karpenter.irsa_oidc_provider_arn # module.eks.oidc_provider_arn
  irsa_namespace_service_accounts = ["karpenter:karpenter"]
  tags = var.karpenter.base_tags
}

module "aws_csi_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "4.24"

  count = var.aws_installations.storage_efs.eks_irsa_role || var.aws_installations.storage_ebs.eks_irsa_role ? 1 : 0

  role_name = "${var.app_name}-${var.app_namespace}-${var.tfenv}-AmazonEKS-CSI_Driver-role"
  role_path = "/${var.app_name}/${var.app_namespace}/${var.tfenv}/"

  attach_ebs_csi_policy = var.aws_installations.storage_ebs.eks_irsa_role
  attach_efs_csi_policy = var.aws_installations.storage_efs.eks_irsa_role

  oidc_providers = {
    main = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = local.namespace_service_accounts
    }
  }
}

locals {
  namespace_service_accounts = concat(
    var.aws_installations.storage_efs.eks_irsa_role ? ["kube-system:efs-csi-controller-sa"] : [],
    var.aws_installations.storage_ebs.eks_irsa_role ? ["kube-system:ebs-csi-controller-sa"] : []
  )
}
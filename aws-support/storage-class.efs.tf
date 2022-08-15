resource "helm_release" "aws-efs-csi-driver" {
  count = var.aws_installations.storage_efs.efs ? 1 : 0

  name         = "aws-efs-csi-driver"
  repository   = "https://kubernetes-sigs.github.io/aws-efs-csi-driver"
  chart        = "aws-efs-csi-driver"
  namespace    = "kube-system"
  force_update = "true"

  set {
    name  = "image.repository"
    value = "602401143452.dkr.ecr.${var.aws_region}.amazonaws.com/eks/aws-efs-csi-driver"
  }

  set {
    name  = "controller.serviceAccount.create"
    value = true
  }

  set {
    name  = "controller.serviceAccount.name"
    value = "efs-csi-controller-sa"
  }

  set {
    name  = "controller.serviceAccount.annotations.eks\\.amazonaws\\.com\\/role\\-arn"
    value = module.aws_csi_irsa_role[0].iam_role_arn
    type  = "string"
  }

  set {
    name  = "replicaCount"
    value = var.node_count
    type  = "string"

  }
}

resource "kubernetes_storage_class" "efs-storage-class" {
  count = var.aws_installations.storage_efs.efs ? 1 : 0

  metadata {
    name = "efs"
  }
  storage_provisioner = "efs.csi.aws.com"
  reclaim_policy      = "Retain"
}

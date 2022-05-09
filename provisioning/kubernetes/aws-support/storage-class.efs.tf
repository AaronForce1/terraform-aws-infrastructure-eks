resource "helm_release" "aws-efs-csi-driver" {
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
    value = aws_iam_role.amazoneks-efs-csi-driver-role.arn
    type  = "string"
  }

  set {
    name  = "replicaCount"
    value = var.node_count
    type  = "string"

  }

  #set {
  #    name = "controller.serviceAccount.annotations"
  #    value = "eks.amazonaws.com/role-arn: arn:aws:iam::${data.aws_caller_identity.aws-support.account_id}:role/${var.app_name}-${var.app_namespace}-${var.tfenv}-AmazonEKS-EFS_CSI_Driver-role"
  #}
}

resource "kubernetes_storage_class" "efs-storage-class" {
  metadata {
    name = "efs"
  }
  storage_provisioner = "efs.csi.aws.com"
  reclaim_policy      = "Retain"
}

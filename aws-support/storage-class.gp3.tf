#resource "helm_release" "gp3-storage-class" {
#  count = try(var.aws_installations.storage_ebs.gp3, false) ? 1 : 0
#
#  name       = "aws-ebs-csi-driver"
#  repository = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
#  chart      = "aws-ebs-csi-driver"
#  namespace  = "kube-system"
#
#  set {
#    name  = "image.repository"
#    value = "602401143452.dkr.ecr.${var.aws_region}.amazonaws.com/eks/aws-ebs-csi-driver"
#  }
#
#  set {
#    name  = "controller.serviceAccount.create"
#    value = true
#  }
#
#  set {
#    name  = "controller.serviceAccount.name"
#    value = "ebs-csi-controller-sa"
#  }
#
#  set {
#    name  = "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
#    value = module.aws_csi_irsa_role[0].iam_role_arn
#  }
#}
#
resource "kubernetes_storage_class" "gp3-storage-class" {
  count = try(var.aws_installations.storage_ebs.gp3, false) ? 1 : 0
  metadata {
    name = "gp3"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "false"
    }
  }
  storage_provisioner = "ebs.csi.aws.com"
  reclaim_policy      = "Retain"
  parameters = {
    type   = "gp3"
    fsType = "ext4"
  }
}

resource "helm_release" "gp3-storage-class" {
  name       = "aws-ebs-csi-driver"
  repository = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
  chart      = "aws-ebs-csi-driver"
  namespace           = "kube-system"

  set {
    name = "image.repository"
    value = "602401143452.dkr.ecr.${var.aws_region}.amazonaws.com/eks/aws-ebs-csi-driver"
  }

  set {
    name = "controller.serviceAccount.create"
    value = true
  }

  set {
    name = "controller.serviceAccount.name"
    value = "ebs-csi-controller-sa"
  }

  set {
    name = "controller.serviceAccount.annotations.eks.amazonaws.com/role-arn"
    value = aws_iam_role.amazoneks-ebs-csi-driver-role.arn
  }
}

resource "kubernetes_storage_class" "gp3-storage-class" {
  metadata {
    name = "gp3"
  }
  storage_provisioner = "ebs.csi.aws.com"
}
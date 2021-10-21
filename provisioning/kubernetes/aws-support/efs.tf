resource "helm_release" "aws-efs-csi-driver" {
  name       = "aws-efs-csi-driver"
  repository = "https://kubernetes-sigs.github.io/aws-efs-csi-driver"
  chart               = "aws-efs-csi-driver"
  namespace           = "kube-system"
  force_update = "true"

  set {
      name = "image.repository"
      value = "602401143452.dkr.ecr.${var.aws_region}.amazonaws.com/eks/aws-efs-csi-driver"
  }

  #set {
  #    name = "controller.serviceAccount.annotations"
  #    value = "eks.amazonaws.com/role-arn: arn:aws:iam::${data.aws_caller_identity.aws-support.account_id}:role/${var.app_name}-${var.app_namespace}-${var.tfenv}-AmazonEKS-EFS_CSI_Driver-role"
  #}
}
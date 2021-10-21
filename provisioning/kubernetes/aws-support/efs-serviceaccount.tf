#resource "kubernetes_service_account" "efs-csi-controller-service-account" {
#  depends_on = [helm_release.aws-efs-csi-driver]
#  metadata {
#    name = "efs-csi-controller-sa"
#    namespace = "kube-system"
#    labels = {
#        "app.kubernetes.io/name": "aws-efs-csi-driver"
#    }
#    annotations = {
#        "eks.amazonaws.com/role-arn": "${data.aws_caller_identity.aws-support.account_id}:role/${var.app_name}-${var.app_namespace}-${var.tfenv}-AmazonEKS-EFS_CSI_Driver-role"
#    } 
#  }
#  automount_service_account_token = true
#}
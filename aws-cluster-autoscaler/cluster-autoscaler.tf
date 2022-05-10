resource "helm_release" "aws-cluster-autoscaler" {
  name             = "aws-cluster-autoscaler-${var.app_namespace}-${var.tfenv}"
  repository       = "https://kubernetes.github.io/autoscaler"
  chart            = "cluster-autoscaler"
  namespace        = "kube-system"
  create_namespace = false

  values = [yamlencode({
    "awsRegion" = var.aws_region,
    "rbac" = {
      "create" : true,
      "serviceAccount" : {
        "name" : "aws-cluster-autoscaler-service-account",
        "annotations" : {
          "eks.amazonaws.com/role-arn" : "${module.iam_assumable_role_admin.iam_role_arn}"
        }
      }
    },
    "autoDiscovery" = {
      clusterName : "${var.app_name}-${var.app_namespace}-${var.tfenv}",
      enabled : true
    }
    })
  ]
}

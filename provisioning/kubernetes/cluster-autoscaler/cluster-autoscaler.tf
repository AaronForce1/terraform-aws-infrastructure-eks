resource "helm_release" "aws-cluster-autoscaler" {
  name             = "aws-cluster-autoscaler-${var.app_namespace}-${var.tfenv}"
  repository       = "https://kubernetes.github.io/autoscaler"
  chart            = "cluster-autoscaler"
  namespace        = "kube-system"
  create_namespace = false
  verify           = false

  values = [
    # file("${path.module}/values.v0.7.0.yaml")
    local_file.values_yaml.content
  ]
}

resource "local_file" "values_yaml" {
  content  = yamlencode(local.helmChartValues)
  filename = "${path.module}/src/values.overrides.v9.9.0.yaml"
}

locals {
  helmChartValues = {
    "awsRegion" = var.aws_region,
    "rbac" = {
      "create" : true,
      "serviceAccount" : {
        "name" : "aws-cluster-autoscaler",
        "annotations" : [
          {
            "\"eks\\.amazonaws\\.com/role-arn\"" : module.iam_assumable_role_admin.this_iam_role_arn
          }
        ]
      }
    },
    "autoDiscovery" = {
      clusterName : "${var.app_name}-${var.app_namespace}-${var.tfenv}",
      enabled : true
    }
  }
}

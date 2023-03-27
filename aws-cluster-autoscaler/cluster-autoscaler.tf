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
          "eks.amazonaws.com/role-arn" : module.iam_assumable_role_admin.iam_role_arn
        }
      }
    },
    "autoDiscovery" = {
      clusterName : "${var.app_name}-${var.app_namespace}-${var.tfenv}",
      enabled : true
    },
    "extraArgs" = {
      "scale-down-utilization-threshold" : var.scale_down_util_threshold,
      "skip-nodes-with-local-storage" : var.skip_nodes_with_local_storage,
      "skip-nodes-with-system-pods" : var.skip_nodes_with_system_pods,
      "cordon-node-before-terminating" : var.cordon_node_before_term,
    }
    })
  ]
}

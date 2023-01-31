resource "helm_release" "teleport" {
  name             = "teleport-agent"
  repository       = "https://charts.releases.teleport.dev"
  chart            = "teleport-kube-agent"
  namespace        = "teleport"
  create_namespace = false
  version          = var.chart_version
  values = var.custom_manifest != null ? [file(var.custom_manifest.value_file)] : [<<EOT

kubeClusterName: ${var.cluster_name}
EOT
  ]
}
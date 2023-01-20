resource "helm_release" "teleport" {
  name             = "teleport-agent"
  repository       = "https://charts.releases.teleport.dev"
  chart            = "teleport/teleport-kube-agent"
  namespace        = "teleport"
  create_namespace = false
  version          = var.chart_version
  values = var.custom_manifest != null ? [var.custom_manifest] : [<<EOT

kubeClusterName  = ${var.cluster_name}
authToken        = ${var.auth_token}
proxyAddr        = ${var.proxy_address}
roles            = ${var.roles}
EOT
  ]
}
data "twingate_connector" "connector" {
  count = var.connector_count

  id = twingate_connector.aws_connector[count.index].id
}
resource "helm_release" "twingate" {
  # for_each = {
  #   for connector in twingate_connector.aws_connector : connector.name => connector
  # }
  count = var.connector_count
  depends_on = [
    kubernetes_secret.kubernetes_secret
  ]

  name             = "twingate-${data.twingate_connector.connector[count.index].name}"
  repository       = "https://twingate.github.io/helm-charts"
  chart            = "connector"
  version          = var.chart_version
  namespace        = "twingate"
  create_namespace = false
  force_update     = true
  recreate_pods    = true

  values = var.custom_manifest != null ? [var.custom_manifest] : [<<EOT
image:
  repository: ${var.image_url}
  tag: 1
  pullPolicy: Always

# additionalLabels: {}
# podAnnotations: {}
# nodeSelector: {}
# tolerations: []
# affinity: {}

env:
  TWINGATE_LOG_ANALYTICS: "v1"

# Enable the Linux kernel's net.ipv4.ping_group_range parameter to allow ping connector.
# Use only if you enable this sysctls in your cluster (disabled by default)
# Or have Kubernetes master higher than 1.18
# (https://kubernetes.io/docs/tasks/administer-cluster/sysctl-cluster/#enabling-unsafe-sysctls)
icmpSupport:
  enabled: false

connector:
  logLevel: ${var.logLevel}
  network: ${var.network_name}
  url: ${var.url}
  existingSecret: "twingate-credentials-${data.twingate_connector.connector[count.index].name}"
  dnsServer:
EOT
  ]
}
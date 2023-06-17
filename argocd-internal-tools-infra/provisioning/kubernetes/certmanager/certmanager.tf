resource "helm_release" "certmanager" {
  depends_on       = [kubernetes_namespace.cert-manager]
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = "v1.5.3"
  namespace        = "cert-manager"
  create_namespace = true

  values = var.custom_manifest != null ? [var.custom_manifest] : [<<EOT
installCRDs: true
EOT
  ]
}

variable "custom_manifest" {
  default = null
}

resource "helm_release" "certmanager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = "v1.9.1"
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

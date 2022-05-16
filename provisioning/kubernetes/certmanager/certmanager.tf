resource "helm_release" "certmanager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = "v1.5.3"
  namespace        = "cert-manager"
  create_namespace = true

  set {
    name  = "installCRDs"
    value = true
  }
}

resource "helm_release" "cert-manager-issuers-letsencrypt" {
  name             = "cert-manager-issuers-letsencrypt"
  repository       = "https://rubenv.github.io/helm-cert-manager-issuers-letsencrypt"
  chart            = "cert-manager-issuers-letsencrypt"

  set {
    name  = "email"
    value = var.letsencrypt_email
  }
}

variable "letsencrypt_email" {}

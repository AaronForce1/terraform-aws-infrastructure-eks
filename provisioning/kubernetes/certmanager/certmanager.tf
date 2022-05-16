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
  repository       = "https://charts.loft.sh"
  chart            = "cert-issuer

  set {
    name  = "certIssuer.email"
    value = var.letsencrypt_email
  }
  set {
    name  = "certIssuer.name"
    value = "letsencrypt-prod"
  }
  set {
    name  = "certIssuer.secretName"
    value = "letsencrypt-prod"
  }
}

variable "letsencrypt_email" {}

resource "helm_release" "cert-manager-issuers-letsencrypt" {
  name       = "cert-manager-issuers-letsencrypt"
  repository = "https://charts.loft.sh"
  chart      = "cert-issuer"

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

  depends_on = [
    helm_release.certmanager
  ]

}

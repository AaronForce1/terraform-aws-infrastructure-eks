resource "kubernetes_manifest" "buypass_tls_prod2" {
  provider = kubernetes-alpha

  manifest = {
    "apiVersion" = "cert-manager.io/v1alpha2"
    "kind"       = "ClusterIssuer"
    "metadata" = {
      "name" = "buypass-tls-prod"
    },
    "spec" = {
      "acme" = {
        "email"  = "",
        "server" = "https://api.buypass.com/acme/directory",
        "privateKeySecretRef" = {
          "name" = "buypass-tls-prod"
        },
        "solvers" = [{
          "http01" = {
            "ingress" = {
              "class" = "nginx"
            }
          }
        }]
      }
    }
  }

  depends_on = [helm_release.certmanager]
}
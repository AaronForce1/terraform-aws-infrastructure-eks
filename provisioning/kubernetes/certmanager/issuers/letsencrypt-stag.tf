resource "kubernetes_manifest" "letsencrypt_stag" {
  provider = kubernetes-alpha

  manifest = {
    "apiVersion" = "cert-manager.io/v1alpha2"
    "kind"       = "ClusterIssuer"
    "metadata" = {
      "name" = "letsencrypt-stag"
    },
    "spec" = {
      "acme" = {
        "email"  = "",
        "server" = "https://acme-staging-v02.api.letsencrypt.org/directory",
        "privateKeySecretRef" = {
          "name" = "letsencrypt-stag"
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
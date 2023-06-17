#resource "kubernetes_manifest" "letsencrypt-prod" {
#  depends_on = [
#    helm_release.certmanager
#  ]
#  manifest = {
#    "apiVersion" = "cert-manager.io/v1"
#    "kind"       = "ClusterIssuer"
#    "metadata" = {
#      "name" = "letsencrypt-prod"
#    }
#    "spec" = {
#      "acme" = {
#        "email" : ""
#        "server" : "https://acme-v02.api.letsencrypt.org/directory"
#        "privateKeySecretRef" : {
#          "name" : "letsencrypt-prod"
#        }
#        "solvers" : [
#          {
#            "http01" : {
#              "ingress" : {
#                "class" : "nginx"
#              }
#            }
#          }
#        ]
#      }
#    }
#  }
#}

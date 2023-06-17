resource "kubernetes_ingress" "kibana_oauth_ingress" {
  metadata {
    name      = "oauth2-proxy"
    namespace = "monitoring"
    annotations = {
      "cert-manager.io/cluster-issuer" = "letsencrypt-prod",
      "kubernetes.io/ingress.class"    = "nginx",
      "kubernetes.io/tls-acme"         = "true",
      "terraform" : "true"
    }

  }

  spec {
    rule {
      host = "kibana.${var.app_namespace}-${var.tfenv}.${var.root_domain_name}"
      http {
        path {
          path = "/oauth2"
          backend {
            service_name = "elasticstack-oauth2-proxy"
            service_port = 80
          }
        }
      }
    }

    tls {
      hosts       = ["kibana.${var.app_namespace}-${var.tfenv}.${var.root_domain_name}"]
      secret_name = "kibana-ing-tls-secret"
    }
  }
}

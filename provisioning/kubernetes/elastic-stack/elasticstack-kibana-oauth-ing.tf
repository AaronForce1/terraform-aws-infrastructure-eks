resource "kubernetes_ingress" "kibana_oauth_ingress" {
  metadata {
    name      = "oauth2-proxy"
    namespace = "gitlab-managed-apps"
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
      secret_name = "kibana-oauth-ingress-tls-secret"
    }
  }
}
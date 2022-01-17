resource "helm_release" "elasticstack-kibana" {
  name       = "kibana"
  repository = "https://helm.elastic.co"
  chart      = "kibana"
  version    = format("v%s", local.elkversion)
  namespace  = "monitoring"

  values = [<<EOF
imagePullPolicy: Always
ingress:
  enabled: true
  annotations:
    kubernetes.io/ingress.class: nginx
    cert-manager.io/cluster-issuer: letsencrypt-prod
    nginx.ingress.kubernetes.io/auth-signin: "https://kibana.${var.app_namespace}-${var.tfenv}.${var.root_domain_name}/oauth2/start?rd=$escaped_request_uri"
    nginx.ingress.kubernetes.io/auth-url: "https://kibana.${var.app_namespace}-${var.tfenv}.${var.root_domain_name}/oauth2/auth"
  hosts:
  - host: "kibana.${var.app_namespace}-${var.tfenv}.${var.root_domain_name}"
    paths:
      - path: "/"
  tls:
    - secretName: kibana-ing-tls-secret
      hosts: 
      - "kibana.${var.app_namespace}-${var.tfenv}.${var.root_domain_name}"
    EOF
  ]
}

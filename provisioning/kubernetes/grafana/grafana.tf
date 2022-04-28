resource "helm_release" "grafana" {
  name       = "grafana-${var.app_namespace}-${var.tfenv}"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  namespace  = "monitoring"

  values = var.custom_manifest != null ? [var.custom_manifest] : [<<EOT
ingress:
  enabled: "true"
  annotations:
    kubernetes.io/ingress.class: nginx
    kubernetes.io/tls-acme: "true"
    cert-manager.io/cluster-issuer: letsencrypt-prod
  labels:
    env: ${var.tfenv}
    app: grafana
    tier: support
  hosts:
    - "grafana.${var.app_namespace}-${var.tfenv}.${var.root_domain_name}"
  tls:
    - secretName: "grafana-${var.app_namespace}-${var.tfenv}-ing-tls"
      hosts:
        - "grafana.${var.app_namespace}-${var.tfenv}.${var.root_domain_name}"
persistence:
  enabled: "true"
  size: "${var.tfenv == "prod" ? "60Gi" : "20Gi"}"
  storageClassName: "gp3"
datasources:
  datasources.yaml:
    apiVersion: 1
    datasources:
      - name: Prometheus
        type: prometheus
        url: http://prometheus-prometheus-server.gitlab-managed-apps.svc.cluster.local
        access: proxy
grafana.ini:
  server:
    root_url: "https://grafana.${var.app_namespace}-${var.tfenv}.${var.root_domain_name}"
  auth.google:
    enabled: "true"
    allow_sign_up: "true"
    client_id: ${var.google_clientID}
    client_secret: ${var.google_clientSecret}
    scopes: "https://www.googleapis.com/auth/userinfo.profile https://www.googleapis.com/auth/userinfo.email"
    token_url: "https://kibana.${var.app_namespace}-${var.tfenv}.${var.root_domain_name}/oauth2/token"
    auth_url: "https://kibana.${var.app_namespace}-${var.tfenv}.${var.root_domain_name}/oauth2/auth"
    api_url: "https://www.googleapis.com/oauth2/v1/userinfo"
    allowed_domains: "${var.google_authDomain}"
dashboardProviders:
  dashboardproviders.yaml:
    apiVersion: 1
    providers:
      - name: default
        orgId: 1
        folder: ""
        type: "file"
        disableDeletion: "false"
        editable: "true"
        options:
          path: "/var/lib/grafana/dashboards/default"
          foldersFromFilesStructure: "true"
dashboards:
  default:
    storage-volume-dashboard:
      gnetId: 11454
      datasource: Prometheus
    k8-cluster-detailed-dashboard:
      gnetId: 10856
      datasource: Prometheus
    coredns-dashboard:
      gnetId: 7279
      datasource: Prometheus
    k8s-cluster-summary-dashboard:
      gnetId: 8685
      datasource: Prometheus
    k8s-app-metrics-dashboard:
      gnetId: 1471
      datasource: Prometheus
    k8s-capacity-dashboard:
      gnetId: 5228
      datasource: Prometheus
    k8s-cluster-dashboard:
      gnetId: 6417
      datasource: Prometheus
    k8s-cpu-mem-network-dashboard:
      gnetId: 5225
      datasource: Prometheus
    k8s-detailed-node-dashboard:
      gnetId: 12740
      datasource: Prometheus
    k8s-cpu-mem-net-pod-dashboard:
      gnetId: 6588
      datasource: Prometheus
    pod-stat-info-dashboard:
      gnetId: 10518
      datasource: Prometheus
imageRenderer:
  enabled: "true"
EOT
  ]
}

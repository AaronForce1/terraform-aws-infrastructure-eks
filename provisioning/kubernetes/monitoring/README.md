# Monitoring-Stack
- Prometheus
- Grafana
- Kube-State-Metrics
- Node-Exporters

Our entire monitoring stack is provisioned through this simple helm chart, found at: https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack

We use grafana for the benefit of graphing the vast metrics of Prometheus. In this case we will use the built in Prometheus server from Gitlab that collects Kubernetes metrics.

## Grafana Configuration Defaults

For ingress:

```
ingress:
  enabled: true
  ingressClassName: nginx
  annotations: 
    kubernetes.io/ingress.class: nginx
    kubernetes.io/tls-acme: "true"
    cert-manager.io/cluster-issuer: letsencrypt-prod
  labels: {}
  path: /
  hosts:
    - <domainyouwant>.mydomain.com
  tls: 
   - secretName: chart-shared-tls
     hosts:
       - <domainyouwant>.mydomain.com
```

For Datasources:

```
datasources:
  datasources.yaml:
    apiVersion: 1
    datasources:
    - name: Prometheus
      type: prometheus
      url: http://prometheus-prometheus-server.<k8snamespace>.svc.cluster.local
      access: proxy
```

For oauth configuration:

```
  auth.google:
    enabled: true
    allow_sign_up: true
    client_id: <Google Client ID>
    client_secret: <Google Client Secret>
    scopes: https://www.googleapis.com/auth/userinfo.profile https://www.googleapis.com/auth/userinfo.email
    auth_url: https://accounts.google.com/o/oauth2/auth
    token_url: https://accounts.google.com/o/oauth2/token
    api_url: https://www.googleapis.com/oauth2/v1/userinfo
    allowed_domains: mydomain.com #email address to whitelist
```

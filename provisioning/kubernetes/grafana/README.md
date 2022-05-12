#Grafana

We use grafana for the benefit of graphing the vast metrics of Prometheus. In this case we will use the built in Prometheus server from Gitlab that collects Kubernetes metrics.

#Installing Grafana

We use helm charts to install grafana. We have a custom helm chart values located at `provisioning/kubernetes/grafana/src/values.7.4.2.yaml`

You need to change some lines to match the environment/cluster where you want grafana installed. In this case you can define the domain you want.

For ingress:

```
ingress:
  enabled: true
  # For Kubernetes >= 1.18 you should specify the ingress-controller via the field ingressClassName
  # See https://kubernetes.io/blog/2020/04/02/improvements-to-the-ingress-api-in-kubernetes-1.18/#specifying-the-class-of-an-ingress
  # ingressClassName: nginx
  # Values can be templated
  annotations: #{}
    kubernetes.io/ingress.class: nginx
    kubernetes.io/tls-acme: "true"
    cert-manager.io/cluster-issuer: letsencrypt-prod
  labels: #{}
  path: /
  hosts:
    #- chart-example.local
    - <domainyouwant>.mydomain.com
  ## Extra paths to prepend to every host configuration. This is useful when working with annotation based services.
  extraPaths: []
  # - path: /*
  #   backend:
  #     serviceName: ssl-redirect
  #     servicePort: use-annotation
  tls: #[]
   - secretName: chart-ets-shared-uat1-tls
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
  server:
    root_url: https://grafana.<cluster>.tech.mydomain.com
# This is for gitlab authentication    
#  auth.gitlab:
#    enabled: true
#    allow_sign_up: false
#    client_id: <Google Client ID>
#    client_secret: <Google Client Secret>
#    scope: read_api
#    auth_url: https://git.hk.asiaticketing.com/oauth/authorize
#    token_url: https://git.hk.asiaticketing.com/oauth/token
#    api_url: https://git.hk.asiaticketing.com/api/v4
#    allowed_groups: whitelabels 
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

Then install grafana using helm by:

`helm install grafana grafana/grafana -f provisioning/kubernetes/grafana/src/values.v7.4.2.yaml -n monitoring`

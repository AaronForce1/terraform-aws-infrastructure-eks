resource "helm_release" "argocd" {
  name        = "argocd"
  repository  = "https://argoproj.github.io/argo-helm"
  chart       = "argo-cd"
  namespace   = "argocd"
  create_namespace = false

  ## Default values.yaml + configuration
  ## https://github.com/argoproj/argo-helm/blob/master/charts/argo-cd/values.yaml
  values      = var.custom_manifest != null ? [var.custom_manifest] : [<<EOT
server:
  env:
    - name: ARGOCD_API_SERVER_REPLICAS
      value: '1'
  ingress:
    enabled: true
    ingressClassName: nginx
    hosts:
      - argocd.${var.root_domain_name}
  extraArgs:
    - --insecure
EOT
  ]
}
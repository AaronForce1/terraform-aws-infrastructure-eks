resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = false
  version          = var.chart_version

  ## Default values.yaml + configuration
  ## https://github.com/argoproj/argo-helm/blob/master/charts/argo-cd/values.yaml
  values = var.custom_manifest != null ? [file(var.custom_manifest.value_file)] : [<<EOT
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

## TODO: Modularise
resource "kubectl_manifest" "applicationset" {
  count = try(length(var.custom_manifest.application_set), 0)
  depends_on = [
    helm_release.argocd
  ]

  yaml_body = templatefile(
    var.custom_manifest.application_set[count.index],
    {
      root_domain_name     = var.root_domain_name,
      operator_domain_name = var.operator_domain_name,
      hosted_zone_id       = var.hosted_zone_id
      kms_key_id           = var.kms_key_id
    }
  )
}

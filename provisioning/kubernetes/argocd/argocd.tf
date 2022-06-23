resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  # chart            = "../../../../../SYSTEM/CLUSTERS/infra/develop/argo-cd"
  namespace        = "argocd"
  create_namespace = false

  ## Default values.yaml + configuration
  ## https://github.com/argoproj/argo-helm/blob/master/charts/argo-cd/values.yaml
  values = var.custom_manifest != null ? [var.custom_manifest.value_file] : [<<EOT
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

# resource "kubernetes_manifest" "applicationset" {
#   # for_each = toset(var.custom_manifest.application_set)
#   manifest = yamldecode(templatefile(
#     "${var.custom_manifest.application_set[0]}", 
#     {
#       domain = "testing",
#       hostzone_id = "test2"
#     }
#   ))
# }

# resource "kubectl_manifest" "applicationset" {
#   yaml_body = templatefile(
#     "${var.custom_manifest.application_set[0]}", 
#     {
#       root_domain_name = var.root_domain_name,
#       hostzone_id = var.hostzone_id
#     }
#   )
# }
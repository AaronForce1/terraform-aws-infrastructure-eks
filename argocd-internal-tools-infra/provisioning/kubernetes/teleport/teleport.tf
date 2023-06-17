resource "helm_release" "teleport" {
  depends_on = [kubernetes_namespace.teleport]
  for_each = {
    for app in var.teleport_installations : app.chart_name => app
  }
  name             = each.value.chart_name
  repository       = "https://charts.releases.teleport.dev"
  chart            = each.value.chart_name
  namespace        = "teleport"
  create_namespace = false
  version          = each.value.chart_version
  values           = each.value.values_file != null ? [each.value.values_file] : []
}
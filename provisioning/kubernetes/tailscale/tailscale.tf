resource "helm_release" "tailscale" {
  name             = "tailscale-${var.app_namespace}-${var.tfenv}"
  chart            = "./chart"
  namespace        = "tailscale"
  create_namespace = true
}
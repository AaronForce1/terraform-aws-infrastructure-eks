resource "helm_release" "nginx-controller" {
  name             = "nginx-controller"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = "3.21.0"
  namespace        = "ingress-nginx"
  create_namespace = true
}

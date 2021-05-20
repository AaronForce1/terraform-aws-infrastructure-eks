resource "helm_release" "nginx-controller" {
  name             = "nginx-controller"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = "3.21.0"
  namespace        = "ingress-nginx"
  create_namespace = true

  values = [
    local_file.values_yaml.content
  ]
}

resource "local_file" "values_yaml" {
  content  = yamlencode(local.helmChartValues)
  filename = "${path.module}/src/values.overrides.v0.30.0.yaml"
}

locals {
  helmChartValues = {
    "controller" = {
      "service": {
        "annotations": {
          "service.beta.kubernetes.io/aws-load-balancer-backend-protocol": "tcp"
          "service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled": "true"
          "service.beta.kubernetes.io/aws-load-balancer-type": "nlb"
        }
      }
    }
  }
}
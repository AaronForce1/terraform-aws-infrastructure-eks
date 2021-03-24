resource "helm_release" "elasticstack-kibana" {
  name       = "kibana"
  repository = "https://helm.elastic.co"
  chart               = "kibana"
  version             = "v7.11.2"
  namespace           = "monitoring"

  values = [
    local_file.kibana_values_yaml.content
  ]
}

resource "local_file" "kibana_values_yaml" {
  content   = yamlencode(local.kibana_helmChartValues)
  filename  = "${path.module}/src/kibana.values.overrides.yaml"
}

locals {
  kibana_helmChartValues = {
    "imagePullPolicy" = "Always",
    "ingress" = {
      "enabled": "true",
      "annotations": {
        "kubernetes.io/ingress.class": "nginx",
        "cert-manager.io/cluster-issuer": "letsencrypt-prod"
        "nginx.ingress.kubernetes.io/auth-signin" = "https://kibana.${var.app_namespace}-${var.tfenv}.${var.root_domain_name}/oauth2/start?rd=$escaped_request_uri"
        "nginx.ingress.kubernetes.io/auth-url" = "https://kibana.${var.app_namespace}-${var.tfenv}.${var.root_domain_name}/oauth2/auth"
      },
      "hosts": [
        {
          "host": "kibana.${var.app_namespace}-${var.tfenv}.${var.root_domain_name}",
          "paths": [
            {
              "path": "/"
            }
          ]
        }
      ],
      "tls": [
        {
          "secretName": "kibana-ing-tls-secret",
          "hosts": [
            "kibana.${var.app_namespace}-${var.tfenv}.${var.root_domain_name}"
          ]
        }
      ]
    }
  }
}

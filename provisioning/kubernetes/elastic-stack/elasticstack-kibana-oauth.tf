resource "helm_release" "elasticstack-oauth2-proxy" {
  name       = "elasticstack-oauth2-proxy"
  repository = "https://charts.helm.sh/stable"
  chart      = "oauth2-proxy"
  version    = "3.2.5"
  namespace  = "gitlab-managed-apps"

  values = [
    # file("${path.module}/values.v0.7.0.yaml")
    local_file.kibana_oauth_values_yaml.content
  ]
}

resource "local_file" "kibana_oauth_values_yaml" {
  content  = yamlencode(local.kibana_oauth_helmChartValues)
  filename = "${path.module}/src/oauth.values.overrides.yaml"
}

locals {
  kibana_oauth_helmChartValues = {
    "config" = {
      "clientID" : var.google_clientID,
      "clientSecret" : var.google_clientSecret,
      "cookieSecret" : base64encode(random_string.random.result),
      "configFile" : <<EOF
          pass_basic_auth = false
          pass_access_token = true
          set_authorization_header = true
          pass_authorization_header = true
        EOF
    },
    "image" = {
      "repository" : "quay.io/pusher/oauth2_proxy",
      "tag" : "latest",
      "pullPolicy" : "IfNotPresent"
    },
    "extraArgs" = {
      "provider" : "google",
      "email-domain" : "magneticasia.com",
      "upstream" : "file:///dev/null",
      "http-address" : "0.0.0.0:4180"
    }
  }
}

resource "random_string" "random" {
  length  = 16
  special = true
}
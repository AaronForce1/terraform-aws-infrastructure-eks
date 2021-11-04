resource "helm_release" "elasticstack-oauth2-proxy" {
  name       = "elasticstack-oauth2-proxy"
  repository = "https://charts.helm.sh/stable"
  chart      = "oauth2-proxy"
  version    = "3.2.5"
  namespace  = "monitoring"

  values = [<<EOT
config:
  clientID: "${var.google_clientID}"
  clientSecret: "${var.google_clientSecret}"
  cookieSecret: "${base64encode(random_string.random.result)}"
  configFile: ${local.config_file}
image:
  repository: quay.io/pusher/oauth2_proxy
  tag: latest
  pullPolicy: IfNotPresent
extraArgs:
  provider: google
  email-domain: "${var.google_authDomain}"
  upstream: "file:///dev/null"
  http-address: "0.0.0.0:4180"
EOT
  ]
}

locals {
  config_file = indent(4, yamlencode({ <<-EOF
      pass_basic_auth = false
      pass_access_token = true
      set_authorization_header = true
      pass_authorization_header = true
  EOF
  }))
}

resource "random_string" "random" {
  length  = 16
  special = true
}

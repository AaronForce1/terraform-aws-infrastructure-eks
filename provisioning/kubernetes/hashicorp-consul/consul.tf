resource "helm_release" "consul" {
  name = "consul-${var.app_namespace}-${var.tfenv}"
  repository = "https://helm.releases.hashicorp.com"
  chart               = "consul"
  namespace           = "hashicorp"
  create_namespace    = true

  values = [<<EOF
global:
  domain: consul.${var.app_namespace}-${var.tfenv}.${var.root_domain_name}
  datacenter: ${var.app_name}-${var.app_namespace}-${var.tfenv}
server:
  enabled: true
  replicas: 2
  storageClass: gp3
client:
  enabled: true
ui:
  enabled: true
syncCatalog:
  enabled: false
  toConsul: false
  toK8s: false
connectInject:
  enabled: false
  default: true
controller:
  enabled: true
EOF
  ]
}

variable "app_namespace" {}
variable "tfenv" {}
variable "root_domain_name" {}
variable "app_name" {}

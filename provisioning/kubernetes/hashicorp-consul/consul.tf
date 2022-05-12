resource "helm_release" "consul" {
  name             = "consul-${var.app_namespace}-${var.tfenv}"
  repository       = "https://helm.releases.hashicorp.com"
  chart            = "consul"
  namespace        = "hashicorp"
  create_namespace = true

  values = [<<EOF
global:
  domain: consul.${var.app_namespace}-${var.tfenv}.${var.root_domain_name}
  datacenter: ${var.app_name}-${var.app_namespace}-${var.tfenv}
server:
  ${local.nodeSelector}
  ${local.tolerations}
  enabled: true
  replicas: 2
  storageClass: gp3
client:
  ${local.nodeSelector}
  ${local.tolerations}
  enabled: true
ui:
  ${local.nodeSelector}
  ${local.tolerations}
  enabled: true
syncCatalog:
  enabled: false
  toConsul: false
  toK8s: false
connectInject:
  ${local.nodeSelector}
  ${local.tolerations}
  enabled: false
  default: true
controller:
  ${local.nodeSelector}
  ${local.tolerations}
  enabled: true
EOF
  ]
}

locals {
  nodeSelector = var.vault_nodeselector != "" ? format("nodeSelector: |\n    %s", var.vault_nodeselector) : ""
  tolerations = var.vault_tolerations != "" ? format("tolerations: |\n    - \"key\": \"%s\"\n      \"operator\": \"Equal\"\n      \"value\": \"%s\"\n      \"effect\": \"%s\"", split(":", var.vault_tolerations)[1], split(":", var.vault_tolerations)[2], split(":", var.vault_tolerations)[0]) : ""
}

variable "app_namespace" {}
variable "tfenv" {}
variable "root_domain_name" {}
variable "app_name" {}
variable "vault_nodeselector" {}
variable "vault_tolerations" {}

resource "helm_release" "vault-secrets-webhook" {
  name             = "vault-secrets-webhook-${var.app_namespace}-${var.tfenv}"
  repository       = "https://kubernetes-charts.banzaicloud.com"
  chart            = "vault-secrets-webhook"
  namespace        = "hashicorp"
  create_namespace = false
  values = [<<EOT
${local.nodeSelector}
${local.tolerations}
replicaCount: 2
EOT
  ]
}

locals {
  nodeSelector = var.vault_nodeselector != "" ? format("nodeSelector:\n  %s", var.vault_nodeselector) : ""
  tolerations  = var.vault_tolerations != "" ? format("tolerations: \n- \"key\": \"%s\"\n  \"operator\": \"Equal\"\n  \"value\": \"%s\"\n  \"effect\": \"%s\"", split(":", var.vault_tolerations)[1], split(":", var.vault_tolerations)[2], split(":", var.vault_tolerations)[0]) : ""
}

variable "app_namespace" {}
variable "tfenv" {}
variable "vault_nodeselector" {}
variable "vault_tolerations" {}

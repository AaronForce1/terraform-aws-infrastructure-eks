resource "helm_release" "vault" {
  name             = "vault-${var.app_namespace}-${var.tfenv}"
  repository       = "https://helm.releases.hashicorp.com"
  chart            = "vault"
  namespace        = "hashicorp"
  create_namespace = false

  values = var.custom_manifest != null ? [var.custom_manifest] : [<<EOT
metrics:
  enabled: true
server:
  ${local.nodeSelector}
  extraSecretEnvironmentVars: 
  ${local.extraSecretEnvironmentVars}
  ingress:
    enabled: true
    annotations:
      kubernetes.io/ingress.class: "nginx"
      cert-manager.io/cluster-issuer: "letsencrypt-prod"
    hosts:
    - host: "vault.${var.app_namespace}-${var.tfenv}.${var.root_domain_name}"
    tls:
    - hosts:
      - "vault.${var.app_namespace}-${var.tfenv}.${var.root_domain_name}"
      secretName: vault-ing-tls
  ha:
    ${var.enable_aws_vault_unseal ? local.haConfig_KMS : local.haConfig_default}
EOT
  ]
}

locals {
  nodeSelector = var.vault_nodeselector != "" ? format("nodeSelector: |\n    %s", var.vault_nodeselector) : ""
  ## False positive regarding exposing secrets via local values in terraform; no secrets are exposed as they are managed via k8s secrets
  #tfsec:ignore:GEN002 
  extraSecretEnvironmentVars = var.enable_aws_vault_unseal ? indent(2, yamlencode([
    {
      "envName" : "AWS_ACCESS_KEY_ID",
      "secretName" : "${var.app_name}-${var.app_namespace}-${var.tfenv}-vault-kms-credentials",
      "secretKey" : "AWS_ACCESS_KEY_ID"
    },
    {
      "envName" : "AWS_SECRET_ACCESS_KEY",
      "secretName" : "${var.app_name}-${var.app_namespace}-${var.tfenv}-vault-kms-credentials",
      "secretKey" : "AWS_SECRET_ACCESS_KEY"
    }
  ])) : yamlencode([])
  haConfig_KMS = indent(4, yamlencode({
    enabled : true,
    replicas : 2,
    config : <<-EOF
    ui = true

          listener "tcp" {
            tls_disable = 1
            address = "[::]:8200"
            cluster_address = "[::]:8201"
          }

          seal "awskms" {
            region     = "${var.aws_region}"
            kms_key_id =  "${var.enable_aws_vault_unseal ? aws_kms_key.vault[0].key_id : ""}"
          }

          storage "consul" {
            path = "vault"
            address = "HOST_IP:8500"
          }

          service_registration "kubernetes" {}
  EOF
  }))

  haConfig_default = indent(1, yamlencode({
    enabled : true,
    replicas : 2,
    config : <<EOF
  ui = "true"

  listener "tcp" {
    tls_disable = 1
    address = "[::]:8200"
    cluster_address = "[::]:8201"
  }

  storage "consul" {
    path = "vault"
    address = "HOST_IP:8500"
  }

  service_registration "kubernetes" {}
EOF
  }))
}

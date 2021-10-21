resource "helm_release" "vault" {
  name       = "vault-${var.app_namespace}-${var.tfenv}"
  repository = "https://helm.releases.hashicorp.com"
  chart               = "vault"
  namespace           = "hashicorp"
  create_namespace    = false

  values = [
    <<-EOF
      metrics:
        enabled: true
      server:
        extraSecretEnvironmentVars: ${local.extraSecretEnvironmentVars}
        ingress:
          enabled: true
          annotations:
            kubernetes.io/ingress.class: "nginx"
            cert-manager.io/cluster-issuer: "letsencrypt-prod"
          hosts:
            - host:"vault.${var.app_namespace}-${var.tfenv}.${var.root_domain_name}",
              paths:
                - "/"
          tls:
            secretName: vault-ing-tls
            hosts:
              - "vault.${var.app_namespace}-${var.tfenv}.${var.root_domain_name}"
        ha: ${var.enable_aws_vault_unseal ? local.haConfig_KMS : local.haConfig_default}
    EOF
  ]
}

locals {
  extraSecretEnvironmentVars = var.enable_aws_vault_unseal ? [
      {
        "envName": "AWS_ACCESS_KEY_ID",
        "secretName": "${var.app_name}-${var.app_namespace}-${var.tfenv}-vault-kms-credentials",
        "secretKey": "AWS_ACCESS_KEY_ID"
      },
      {
        "envName": "AWS_SECRET_ACCESS_KEY",
        "secretName": "${var.app_name}-${var.app_namespace}-${var.tfenv}-vault-kms-credentials",
        "secretKey": "AWS_SECRET_ACCESS_KEY"
      }
  ] : []
  haConfig_KMS = {
    "enabled": true,
    "replicas": 2,
    "config": <<EOF
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
  }

  haConfig_default = {
    "enabled": true,
    "replicas": 2,
    "config": <<EOF
      ui = true

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
  }
}

variable "aws_region" {}
variable "app_namespace" {}
variable "tfenv" {}
variable "root_domain_name" {}
variable "app_name" {}
variable "enable_aws_vault_unseal" {}
variable "billingcustomer" {}

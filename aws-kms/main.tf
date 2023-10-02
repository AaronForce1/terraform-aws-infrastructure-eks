locals {
  region           = var.region
  current_identity = data.aws_caller_identity.current.arn
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}


module "kms" {
  source  = "terraform-aws-modules/kms/aws"
  version = "1.5.0"

  deletion_window_in_days  = lookup(var.kms, "deletion_window_in_days", 7)
  description              = lookup(var.kms, "description", "KMS key for encrypt & decrypt")
  enable_key_rotation      = lookup(var.kms, "enable_key_rotation", true)
  is_enabled               = lookup(var.kms, "is_enabled", true)
  key_usage                = lookup(var.kms, "key_usage", "ENCRYPT_DECRYPT")
  multi_region             = lookup(var.kms, "multi_region", false)
  customer_master_key_spec = lookup(var.kms, "customer_master_key_spec", "SYMMETRIC_DEFAULT")

  # Policy
  enable_default_policy                  = lookup(var.kms, "enable_default_policy", true)
  key_owners                             = lookup(var.kms, "key_owners", [local.current_identity])
  key_administrators                     = lookup(var.kms, "key_administrators", [local.current_identity])
  key_users                              = lookup(var.kms, "key_users", [local.current_identity])
  key_service_users                      = lookup(var.kms, "key_service_users", [])
  key_service_roles_for_autoscaling      = lookup(var.kms, "key_service_roles_for_autoscaling", [])
  key_symmetric_encryption_users         = lookup(var.kms, "key_symmetric_encryption_users", [local.current_identity])
  key_hmac_users                         = lookup(var.kms, "key_hmac_users", [local.current_identity])
  key_asymmetric_public_encryption_users = lookup(var.kms, "key_asymmetric_public_encryption_users", [local.current_identity])
  key_asymmetric_sign_verify_users       = lookup(var.kms, "key_asymmetric_sign_verify_users", [local.current_identity])
  key_statements                         = lookup(var.kms, "key_statements", {})
  # Aliases
  aliases                 = lookup(var.kms, "aliases", ["encryp-decrypt-key"])
  aliases_use_name_prefix = lookup(var.kms, "aliases_use_name_prefix", true)
  # Grants
  grants = lookup(var.kms, "grants", {})
  tags   = lookup(var.kms, "tags", {})
}


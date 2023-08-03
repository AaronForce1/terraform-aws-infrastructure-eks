module "rds_backup_plan" {
  source = "../"

  aws_kms_name = "backup-plan-kms"

  backup_vault = {
    backup_vault_name = "backup-vault-metazen-canary"
  }

  backup_vault_lock = {
    enabled                       = false
    vault_lock_max_retention_days = 30
    vault_lock_min_retention_days = 1
  }

  backup_plan = [
    {
      backup_plan_name      = "rds-backup-plan"
      rule_name             = "rds"
      backup_schedule       = "cron(0 19 * * ? *)" # Backup everyday at 7PM UTC
      continuous_backup     = true
      backup_retention_days = 14
      backup_resource_name  = ["arn:aws:rds:ap-southeast-1:886728326230:db:postgres-hexsafe-canary"] # Backup for specific resource
      selection_tag_name    = "rds-slection-tag"
      selection_tags        = []
    },
    {
      backup_plan_name      = "canary-backup-plan"
      rule_name             = "s3"
      backup_schedule       = "cron(0 19 * * ? *)" # Backup everyday at 7PM UTC
      continuous_backup     = true
      backup_retention_days = 14
      selection_tag_name    = "canary"
      selection_tags = [ # Backup base on tags
        {
          type  = "STRINGEQUALS"
          key   = "terraform/env"
          value = "canary"
        }
      ]
    }
  ]
}


provider "aws" {
  region = "ap-southeast-1"
}

provider "aws" {
  region = "us-east-1"
  alias  = "secondary"
}
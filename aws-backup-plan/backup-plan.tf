## ----------------------------------
## AWS BACKUP VAULT
## ----------------------------------
resource "aws_backup_vault" "backup-vault" {
  name        = var.backup_vault.backup_vault_name
  kms_key_arn = aws_kms_key.kms-key.arn
}

## ----------------------------------
## AWS BACKUP VAULT LOCK
## ----------------------------------
# Enable back vault lock to avoid delete backup vault by accident
resource "aws_backup_vault_lock_configuration" "back-vault-lock" {
  count              = var.backup_vault_lock.enabled ? 1 : 0
  backup_vault_name  = aws_backup_vault.backup-vault.name
  max_retention_days = var.backup_vault_lock.vault_lock_max_retention_days
  min_retention_days = var.backup_vault_lock.vault_lock_min_retention_days
}

## ----------------------------------
## AWS BACKUP VAULT PLAN
## ----------------------------------
resource "aws_backup_plan" "backup-plan" {
  depends_on = [aws_backup_vault.backup-vault]
  for_each = {
    for backup in var.backup_plan : backup.backup_plan_name => backup
  }

  name = each.value.backup_plan_name

  rule {
    rule_name                = each.value.rule_name
    target_vault_name        = aws_backup_vault.backup-vault.name
    schedule                 = each.value.backup_schedule
    enable_continuous_backup = each.value.continuous_backup

    lifecycle {
      delete_after = each.value.backup_retention_days
    }
  }
}

## ----------------------------------
## AWS BACKUP VAULT SELECTION
## ----------------------------------
data "aws_iam_policy_document" "backup-assume-role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["backup.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "backup-iam-role" {
  name               = "backup-iam-role"
  assume_role_policy = data.aws_iam_policy_document.backup-assume-role.json
}

resource "aws_iam_role_policy_attachment" "backup-role-policy-attachment" {
  count      = length(local.backup_policy_arn)
  policy_arn = local.backup_policy_arn[count.index]
  role       = aws_iam_role.backup-iam-role.name
}

resource "aws_iam_role_policy_attachment" "s3-backup-role-policy-attachment" {
  count      = length(local.s3_backup_policy_arn)
  policy_arn = local.s3_backup_policy_arn[count.index]
  role       = aws_iam_role.backup-iam-role.name
}

### Backup By Tag
resource "aws_backup_selection" "backup-selection-tag" {
  for_each = {
    for backup in var.backup_plan : backup.backup_plan_name => backup
  }
  iam_role_arn = aws_iam_role.backup-iam-role.arn
  name         = each.value.selection_tag_name
  plan_id      = aws_backup_plan.backup-plan[each.key].id

  resources     = each.value.backup_resource_name
  not_resources = each.value.exclude_resource_name

  dynamic "selection_tag" {
    for_each = each.value.selection_tags
    content {
      type  = selection_tag.value["type"]
      key   = selection_tag.value["key"]
      value = selection_tag.value["value"]
    }
  }
}


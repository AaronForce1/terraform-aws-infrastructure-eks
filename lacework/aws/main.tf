
module "aws_config" {
  source                  = "lacework/config/aws"
  version                 = "~> 0.11"
  lacework_aws_account_id = "434813966438"
  tags                    = {
    "Team" = "Security/Compliance"
    "Terraform" = "true"
  }
}

module "main_cloudtrail" {
  source                  = "lacework/cloudtrail/aws"
  version                 = "~> 2.7.3"
  iam_role_arn            = module.aws_config.iam_role_arn
  iam_role_external_id    = module.aws_config.external_id
  iam_role_name           = module.aws_config.iam_role_name
  lacework_aws_account_id = "434813966438"
  use_existing_iam_role   = true
  tags = merge({
    "Team"      = "Security/Compliance",
    "Terraform" = "true"
  }, lookup(var.lacework, "tags", {}))
}

module "lacework_aws_agentless_scanning_global" {
  source  = "lacework/agentless-scanning/aws"
  version = "~> 0.11.2"

  global                    = true
  lacework_integration_name = "lacework_agentless_global"
}

module "lacework_aws_agentless_scanning_region" {
  source  = "lacework/agentless-scanning/aws"
  version = "~> 0.11.2"

  regional                = true
  global_module_reference = module.lacework_aws_agentless_scanning_global
}

module "aws_eks_audit_log" {
  source                    = "lacework/eks-audit-log/aws"
  version                   = "~> 1.0.3"
  cloudwatch_regions        = lookup(var.lacework, "region", ["ap-southeast-1"])
  cluster_names             = lookup(var.lacework, "eks_cluster_names", ["eks-clsuter"])
  kms_key_multi_region      = false
  lacework_aws_account_id   = "434813966438"
  no_cw_subscription_filter = false
  tags = merge({
    "Team"      = "Security/Compliance",
    "Terraform" = "true"
  }, lookup(var.lacework, "tags", {}))
}

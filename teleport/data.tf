data "aws_caller_identity" "current" {}

data "aws_caller_identity" "destination" { provider = aws.destination-aws-provider }

data "aws_region" "current" {}

data "aws_eks_cluster" "cluster" { name = local.name_prefix }

data "aws_kms_key" "aws-kms-key" { key_id = "alias/${var.app_name}-${var.app_namespace}-${var.tfenv}-kms" }
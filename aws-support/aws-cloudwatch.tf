## IAM Role and Policy
data "aws_iam_policy_document" "aws_cloudwatch_bucket_iam_policy_document" {
  for_each = {
    for bucket in var.eks_aws_cloudwatch : bucket.name => bucket
  }

  statement {
    sid = "AllowReadingMetricsFromCloudWatch"
    actions = [
      "cloudwatch:DescribeAlarmsForMetric",
      "cloudwatch:DescribeAlarmHistory",
      "cloudwatch:DescribeAlarms",
      "cloudwatch:ListMetrics",
      "cloudwatch:GetMetricData",
      "cloudwatch:GetInsightRuleReport"
    ]
    resources = ["*"]
  }

  statement {
    sid = "AllowReadingLogsFromCloudWatch"
    actions = [
      "logs:DescribeLogGroups",
      "logs:GetLogGroupFields",
      "logs:StartQuery",
      "logs:StopQuery",
      "logs:GetQueryResults",
      "logs:GetLogEvents"
    ]
    resources = ["*"]
  }

  statement {
    sid = "AllowReadingTagsInstancesRegionsFromEC2"
    actions = [
      "ec2:DescribeTags", 
      "ec2:DescribeInstances", 
      "ec2:DescribeRegions"
    ]
    resources = ["*"]
  }

  statement {
    sid = "AllowReadingResourcesForTags"
    actions = [
      "tag:GetResources"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "aws_cloudwatch_bucket_iam_policies" {
  for_each = {
    for bucket in var.eks_aws_cloudwatch : bucket.name => bucket
  }

  name        = "${var.app_name}-${var.app_namespace}-${var.tfenv}-cloudwatch-custom-policy-${each.value.name}"
  path        = "/${var.app_name}/${var.app_namespace}/${var.tfenv}/"
  description = "AWS cloudwatch-custom-policy-${each.value.name} policy: ${var.app_name}-${var.app_namespace}-${var.tfenv}"
  policy      = data.aws_iam_policy_document.aws_cloudwatch_bucket_iam_policy_document[each.value.name].json
  tags        = var.tags
}


module "aws_cloudwatch_bucket_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "4.24"

  for_each = {
    for bucket in var.eks_aws_cloudwatch : bucket.name => bucket

  }

  create_role = true

  role_name = "${var.app_name}-${var.app_namespace}-${var.tfenv}-cloudwatch-${each.value.name}"

  role_path    = "/${var.app_name}/${var.app_namespace}/${var.tfenv}/"

  custom_role_policy_arns = [aws_iam_policy.aws_cloudwatch_bucket_iam_policies[each.value.name].arn]

  trusted_role_arns = ["*"]

  role_requires_mfa = false

  tags = var.tags
}
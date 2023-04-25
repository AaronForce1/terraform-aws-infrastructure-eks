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
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "4.24"

  for_each = {
    for bucket in var.eks_aws_cloudwatch : bucket.name => bucket

  }

  create_role = true

  role_name = "${var.app_name}-${var.app_namespace}-${var.tfenv}-aws-cloudwatch-${each.value.name}"

  role_path    = "/${var.app_name}/${var.app_namespace}/${var.tfenv}/"
  provider_url = replace(var.oidc_url, "https://", "")

  role_policy_arns = [aws_iam_policy.aws_cloudwatch_bucket_iam_policies[each.value.name].arn]

  oidc_fully_qualified_subjects = [join("", concat(["system:serviceaccount:"], each.value.k8s_namespace_service_account_access))]

  tags = var.tags
}

locals {
  role_policy_attachments = distinct(flatten([
    for cloudwatch in var.eks_aws_cloudwatch : [
      for role_name in var.eks_managed_node_group_roles : {
        cloudwatch = cloudwatch
        role_name = role_name.value
      }
    ]
    if cloudwatch.eks_node_group_access
  ]))
}

resource "aws_iam_role_policy_attachment" "additional" {
  for_each = {
    for role_attachment in local.role_policy_attachments : "${role_attachment.cloudwatch.name}-${role_attachment.role_name}" => role_attachment
  }

  policy_arn = resource.aws_iam_policy.aws_cloudwatch_bucket_iam_policies[each.value.cloudwatch.name].arn
  role       = each.value.role_name
}
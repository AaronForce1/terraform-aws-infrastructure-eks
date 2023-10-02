## ----------------------------------
## IAM Policy for cluster-state-storage
## ----------------------------------
data "aws_iam_policy_document" "cluster_state_storage" {
  count = try(coalesce(var.teleport_integrations.cluster, false), false) ? 1 : 0

  statement {
    sid    = "ClusterStateStorage"
    effect = "Allow"
    actions = [
      "dynamodb:BatchWriteItem",
      "dynamodb:UpdateTimeToLive",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem",
      "dynamodb:Scan",
      "dynamodb:Query",
      "dynamodb:DescribeStream",
      "dynamodb:UpdateItem",
      "dynamodb:DescribeTimeToLive",
      "dynamodb:CreateTable",
      "dynamodb:DescribeTable",
      "dynamodb:GetShardIterator",
      "dynamodb:GetItem",
      "dynamodb:UpdateTable",
      "dynamodb:GetRecords",
      "dynamodb:UpdateContinuousBackups"
    ]
    resources = [
      "arn:aws:dynamodb:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/${var.app_name}-${var.app_namespace}-${var.tfenv}-teleport-cluster-storage",
      "arn:aws:dynamodb:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/${var.app_name}-${var.app_namespace}-${var.tfenv}-teleport-cluster-storage/stream/*"
    ]
  }
}

resource "aws_iam_policy" "cluster_state_storage" {
  count = try(coalesce(var.teleport_integrations.cluster, false), false) ? 1 : 0

  name        = "${var.app_name}-${var.app_namespace}-${var.tfenv}-teleport-cluster-state"
  path        = "/${var.app_name}/${var.app_namespace}/${var.tfenv}/"
  description = "EKS Policy allowing DynamoDB Access for Teleport State ${var.app_name}-${var.app_namespace}-${var.tfenv}"
  policy      = data.aws_iam_policy_document.cluster_state_storage[0].json
  tags        = local.base_tags
}

## ----------------------------------
## IAM Policy for cluster-events-storage
## ----------------------------------
data "aws_iam_policy_document" "cluster_events_storage" {
  count = try(coalesce(var.teleport_integrations.cluster, false), false) ? 1 : 0

  statement {
    sid    = "ClusterEventsStorage"
    effect = "Allow"
    actions = [
      "dynamodb:CreateTable",
      "dynamodb:BatchWriteItem",
      "dynamodb:UpdateTimeToLive",
      "dynamodb:PutItem",
      "dynamodb:DescribeTable",
      "dynamodb:DeleteItem",
      "dynamodb:GetItem",
      "dynamodb:Scan",
      "dynamodb:Query",
      "dynamodb:UpdateItem",
      "dynamodb:DescribeTimeToLive",
      "dynamodb:UpdateTable",
      "dynamodb:UpdateContinuousBackups"
    ]
    resources = [
      "arn:aws:dynamodb:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/${var.app_name}-${var.app_namespace}-${var.tfenv}-teleport-cluster-audit",
      "arn:aws:dynamodb:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/${var.app_name}-${var.app_namespace}-${var.tfenv}-teleport-cluster-audit/index/*"
    ]
  }
}

resource "aws_iam_policy" "cluster_events_storage" {
  count = try(coalesce(var.teleport_integrations.cluster, false), false) ? 1 : 0

  name        = "${var.app_name}-${var.app_namespace}-${var.tfenv}-teleport-cluster-events"
  path        = "/${var.app_name}/${var.app_namespace}/${var.tfenv}/"
  description = "EKS Policy allowing DynamoDB Access for Teleport State ${var.app_name}-${var.app_namespace}-${var.tfenv}"
  policy      = data.aws_iam_policy_document.cluster_events_storage[0].json
  tags        = local.base_tags
}

## ----------------------------------
## IAM Policy for S3: Session Recording
## ----------------------------------
data "aws_iam_policy_document" "cluster_s3_recording" {
  count = try(coalesce(var.teleport_integrations.cluster, false), false) ? 1 : 0

  statement {
    sid    = "BucketActions"
    effect = "Allow"
    actions = [
      "s3:PutEncryptionConfiguration",
      "s3:PutBucketVersioning",
      "s3:ListBucketVersions",
      "s3:ListBucketMultipartUploads",
      "s3:ListBucket",
      "s3:GetEncryptionConfiguration",
      "s3:GetBucketVersioning",
      "s3:CreateBucket"
    ]
    resources = [
      "arn:aws:s3:::${var.app_name}-${var.app_namespace}-${var.tfenv}-teleport-cluster-session-recordings",
    ]
  }
  statement {
    sid    = "ObjectActions"
    effect = "Allow"
    actions = [
      "s3:GetObjectVersion",
      "s3:GetObjectRetention",
      "s3:*Object",
      "s3:ListMultipartUploadParts",
      "s3:AbortMultipartUpload"
    ]
    resources = [
      "arn:aws:s3:::${var.app_name}-${var.app_namespace}-${var.tfenv}-teleport-cluster-session-recordings/*",
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "kms:GenerateDataKey",
      "kms:Encrypt",
      "kms:Decrypt"
    ]
    resources = [
      data.aws_kms_key.aws-kms-key.arn
    ]
  }
}

resource "aws_iam_policy" "cluster_s3_recording" {
  count = try(coalesce(var.teleport_integrations.cluster, false), false) ? 1 : 0

  name        = "${var.app_name}-${var.app_namespace}-${var.tfenv}-teleport-s3-recordings"
  path        = "/${var.app_name}/${var.app_namespace}/${var.tfenv}/"
  description = "EKS Policy allowing S3 Access for Teleport Recordings ${var.app_name}-${var.app_namespace}-${var.tfenv}"
  policy      = data.aws_iam_policy_document.cluster_s3_recording[0].json
  tags        = local.base_tags
}

## ----------------------------------
## IAM Role for teleport-cluster
## ----------------------------------
module "teleport_cluster_irsa_role" {
  count = try(coalesce(var.teleport_integrations.cluster, false), false) ? 1 : 0

  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.17"

  role_name = "${var.app_name}-${var.app_namespace}-${var.tfenv}-teleport-cluster-role"
  role_path = "/${var.app_name}/${var.app_namespace}/${var.tfenv}/"

  oidc_providers = {
    main = {
      provider_arn               = replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/")
      namespace_service_accounts = ["teleport:teleport-cluster"]
    }
  }

  role_policy_arns = {
    state_storage        = aws_iam_policy.cluster_state_storage[0].arn,
    events_storage       = aws_iam_policy.cluster_events_storage[0].arn,
    s3_session_recording = aws_iam_policy.cluster_s3_recording[0].arn,
  }
}

## ----------------------------------
## IAM Policy for teleport-eks-auto-discovery
## ----------------------------------
data "aws_iam_policy_document" "cluster_discovery" {
  provider = aws.destination-aws-provider
  count    = try(coalesce(var.teleport_integrations.cluster_discovery, false), false) ? 1 : 0

  statement {
    sid    = "AutomatedClusterDiscovery"
    effect = "Allow"
    actions = [
      "eks:DescribeCluster",
      "eks:ListClusters"
    ]
    resources = [
      "arn:aws:eks:${data.aws_region.current.name}:${data.aws_caller_identity.destination.account_id}:cluster/*",
    ]
  }
}

resource "aws_iam_policy" "cluster_discovery" {
  provider = aws.destination-aws-provider
  count    = try(coalesce(var.teleport_integrations.cluster_discovery, false), false) ? 1 : 0

  name        = var.existing_role ? "${var.app_name}-${var.app_namespace}-${var.tfenv}-teleport-eks-discovery" : "${var.app_name}-${var.app_namespace}-${var.tfenv}-${lookup(var.teleport_integrations, "discovered_account", "develop")}-teleport-eksd"
  path        = "/${var.app_name}/${var.app_namespace}/${var.tfenv}/"
  description = "EKS Policy to discover clusters automatically ${var.app_name}-${var.app_namespace}-${var.tfenv}"
  policy      = data.aws_iam_policy_document.cluster_discovery[0].json
  tags        = local.base_tags
}

## ----------------------------------
## IAM Policy for teleport-rds-auto-discovery
## ----------------------------------
data "aws_iam_policy_document" "rds_discovery" {
  provider = aws.destination-aws-provider
  count    = try(coalesce(var.teleport_integrations.rds_discovery, false), false) ? 1 : 0

  statement {
    sid    = "AutomatedRdsDiscovery"
    effect = "Allow"
    actions = [
      "rds:DescribeDBInstances",
      "rds:ModifyDBInstance",
      "rds:DescribeDBClusters"
    ]
    resources = [
      "arn:aws:rds:${data.aws_region.current.name}:${data.aws_caller_identity.destination.account_id}:*:*",
    ]
  }

  statement {
    sid    = "AllowPolicyForIamUser"
    effect = "Allow"
    actions = [
      "iam:GetRolePolicy",
      "iam:PutRolePolicy",
      "iam:DeleteRolePolicy"
    ]
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.destination.account_id}:role/*"
    ]
  }

  statement {
    sid       = "AllowIamUserConnectRds"
    effect    = "Allow"
    actions   = ["rds-db:connect"]
    resources = ["arn:aws:rds-db:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:dbuser:*/*"]
  }
}

resource "aws_iam_policy" "rds_discovery" {
  provider = aws.destination-aws-provider
  count    = try(coalesce(var.teleport_integrations.rds_discovery, false), false) ? 1 : 0

  name        = var.existing_role ? "${var.app_name}-${var.app_namespace}-${var.tfenv}-teleport-rds-discovery" : "${var.app_name}-${var.app_namespace}-${var.tfenv}-${lookup(var.teleport_integrations, "discovered_account", "develop")}-teleport-rd"
  path        = "/${var.app_name}/${var.app_namespace}/${var.tfenv}/"
  description = "EKS Policy to discover rds automatically ${var.app_name}-${var.app_namespace}-${var.tfenv}"
  policy      = data.aws_iam_policy_document.rds_discovery[0].json
  tags        = local.base_tags
}


## ----------------------------------
## IAM Policy for teleport-rds-proxy-auto-discovery
## ----------------------------------
data "aws_iam_policy_document" "rds_proxy_discovery" {
  provider = aws.destination-aws-provider
  count    = try(coalesce(var.teleport_integrations.rds_proxy_discovery, false), false) ? 1 : 0

  statement {
    sid    = "AutomatedRdsProxyDiscovery"
    effect = "Allow"
    actions = [
      "rds:DescribeDBProxies",
      "rds:DescribeDBProxyEndpoints",
      "rds:DescribeDBProxyTargets",
      "rds:ListTagsForResource"
    ]
    resources = [
      "arn:aws:rds:${data.aws_region.current.name}:${data.aws_caller_identity.destination.account_id}:*:*",
    ]
  }

  statement {
    sid    = "AllowPolicyForIamUser"
    effect = "Allow"
    actions = [
      "iam:GetRolePolicy",
      "iam:PutRolePolicy",
      "iam:DeleteRolePolicy"
    ]
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.destination.account_id}:role/*"
    ]
  }
}

resource "aws_iam_policy" "rds_proxy_discovery" {
  provider = aws.destination-aws-provider
  count    = try(coalesce(var.teleport_integrations.rds_proxy_discovery, false), false) ? 1 : 0

  name        = var.existing_role ? "${var.app_name}-${var.app_namespace}-${var.tfenv}-teleport-rds-proxy-discovery" : "${var.app_name}-${var.app_namespace}-${var.tfenv}-${lookup(var.teleport_integrations, "discovered_account", "develop")}-teleport-rpd"
  path        = "/${var.app_name}/${var.app_namespace}/${var.tfenv}/"
  description = "EKS Policy to discover rds proxy automatically ${var.app_name}-${var.app_namespace}-${var.tfenv}"
  policy      = data.aws_iam_policy_document.rds_proxy_discovery[0].json
  tags        = local.base_tags
}

## ----------------------------------
## IAM Role for teleport-kube-agent cross account
## ----------------------------------
module "teleport_kube_agent_trusted_role" {
  providers = { aws = aws.destination-aws-provider }
  count     = try(coalesce(var.teleport_integrations.kube_agent, false), false) ? 1 : 0

  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "5.27.0"

  create_role = true
  role_name   = var.existing_role ? "${var.app_name}-${var.app_namespace}-${var.tfenv}-teleport-kube-agent-trusted-role" : "${var.app_name}-${var.app_namespace}-${var.tfenv}-${lookup(var.teleport_integrations, "discovered_account", "develop")}-teleport-kube-atr"
  role_path   = "/${var.app_name}/${var.app_namespace}/${var.tfenv}/"

  role_sts_externalid = data.aws_caller_identity.current.account_id
  role_requires_mfa   = false
  trusted_role_actions = [
    "sts:AssumeRole"
  ]
  trusted_role_arns = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.app_name}/${var.app_namespace}/${var.tfenv}/${var.app_name}-${var.teleport_integrations.discovered_account}-teleport-kube-agent-assume-role"]
}

resource "aws_iam_policy_attachment" "teleport_kube_agent_cluster_discovery" {
  provider   = aws.destination-aws-provider
  count      = try(coalesce(var.teleport_integrations.cluster_discovery, false), false) ? 1 : 0
  name       = var.existing_role ? "cluster_discovery" : "cluster_discovery-${lookup(var.teleport_integrations, "discovered_account", "develop")}"
  roles      = ["${module.teleport_kube_agent_trusted_role[0].iam_role_name}"]
  policy_arn = aws_iam_policy.cluster_discovery[0].arn
}

resource "aws_iam_policy_attachment" "teleport_kube_agent_rds_discovery" {
  provider   = aws.destination-aws-provider
  count      = try(coalesce(var.teleport_integrations.rds_discovery, false), false) ? 1 : 0
  name       = var.existing_role ? "rds_discovery" : "rds_discovery-${lookup(var.teleport_integrations, "discovered_account", "develop")}"
  roles      = ["${module.teleport_kube_agent_trusted_role[0].iam_role_name}"]
  policy_arn = aws_iam_policy.rds_discovery[0].arn
}

resource "aws_iam_policy_attachment" "teleport_kube_agent_rds_proxy_discovery" {
  provider   = aws.destination-aws-provider
  count      = try(coalesce(var.teleport_integrations.rds_proxy_discovery, false), false) ? 1 : 0
  name       = var.existing_role ? "rds_proxy_discovery" : "rds_proxy_discovery-${lookup(var.teleport_integrations, "discovered_account", "develop")}"
  roles      = ["${module.teleport_kube_agent_trusted_role[0].iam_role_name}"]
  policy_arn = aws_iam_policy.rds_proxy_discovery[0].arn
}

## ----------------------------------
## IAM Policy for teleport-kube-agent-assume-role
## ----------------------------------
data "aws_iam_policy_document" "teleport_kube_agent_assumerole" {
  count = try(coalesce(var.teleport_integrations.kube_agent, false), false) ? 1 : 0

  statement {
    sid    = "AllowAssumeRole"
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    resources = [
      module.teleport_kube_agent_trusted_role[0].iam_role_arn
#      "arn:aws:iam::${data.aws_caller_identity.destination.account_id}:role/${var.app_name}/${var.app_namespace}/${var.tfenv}/${var.app_name}-${var.app_namespace}-${var.tfenv}-teleport-kube-agent-trusted-role"
    ]
  }
}

resource "aws_iam_policy" "teleport_kube_agent_assumerole" {
  count = try(coalesce(var.teleport_integrations.kube_agent, false), false) ? 1 : 0

  name        = "${var.app_name}-${var.teleport_integrations.discovered_account}-teleport-kube-agent-assume-role"
  path        = "/${var.app_name}/${var.app_namespace}/${var.tfenv}/"
  description = "EKS Policy to teleport kube agent assume role ${var.app_name}-${var.app_namespace}-${var.tfenv}"
  policy      = data.aws_iam_policy_document.teleport_kube_agent_assumerole[0].json
  tags        = local.base_tags
}

## ----------------------------------
## IAM Role for teleport-kube-agent-assume-role
## ----------------------------------
  module "teleport_kube_agent_irsa_role" {
  count = try(coalesce(var.teleport_integrations.kube_agent, false), false) ? 1 : 0

  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.17"

  role_name = "${var.app_name}-${var.teleport_integrations.discovered_account}-teleport-kube-agent-assume-role"
  role_path = "/${var.app_name}/${var.app_namespace}/${var.tfenv}/"

  oidc_providers = {
    main = {
      provider_arn               = replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/")
      namespace_service_accounts = ["teleport:${var.teleport_integrations.agent_service_account_name}"]
    }
  }

  role_policy_arns = {
    assume_role = aws_iam_policy.teleport_kube_agent_assumerole[0].arn
  }
}

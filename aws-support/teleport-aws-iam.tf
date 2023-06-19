## ----------------------------------
## IAM Policy for cluster-state-storage
## ----------------------------------
data "aws_iam_policy_document" "cluster_state_storage" {
  count = try(coalesce(var.aws_installations.teleport.cluster, false), false) ? 1 : 0

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
    ## TODO: Restrict resources to cluster-associated only.
    resources = [
      "arn:aws:dynamodb:${var.aws_region}:${data.aws_caller_identity.current.account_id}:table/${var.app_name}-${var.app_namespace}-${var.tfenv}-teleport-storage",
      "arn:aws:dynamodb:${var.aws_region}:${data.aws_caller_identity.current.account_id}:table/${var.app_name}-${var.app_namespace}-${var.tfenv}-teleport-storage/stream/*"
    ]
  }
}

resource "aws_iam_policy" "cluster_state_storage" {
  count = try(coalesce(var.aws_installations.teleport.cluster, false), false) ? 1 : 0

  name        = "${var.app_name}-${var.app_namespace}-${var.tfenv}-teleport-cluster-state"
  path        = "/${var.app_name}/${var.app_namespace}/${var.tfenv}/"
  description = "EKS Policy allowing DynamoDB Access for Teleport State ${var.app_name}-${var.app_namespace}-${var.tfenv}"
  policy      = data.aws_iam_policy_document.cluster_state_storage[0].json
  tags        = var.tags
}

## ----------------------------------
## IAM Policy for cluster-events-storage
## ----------------------------------
data "aws_iam_policy_document" "cluster_events_storage" {
  count = try(coalesce(var.aws_installations.teleport.cluster, false), false) ? 1 : 0

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
    ## TODO: Restrict resources to cluster-associated only.
    resources = [
      "arn:aws:dynamodb:${var.aws_region}:${data.aws_caller_identity.current.account_id}:table/${var.app_name}-${var.app_namespace}-${var.tfenv}-teleport-audit",
      "arn:aws:dynamodb:${var.aws_region}:${data.aws_caller_identity.current.account_id}:table/${var.app_name}-${var.app_namespace}-${var.tfenv}-teleport-audit/index/*"
    ]
  }
}

resource "aws_iam_policy" "cluster_events_storage" {
  count = try(coalesce(var.aws_installations.teleport.cluster, false), false) ? 1 : 0

  name        = "${var.app_name}-${var.app_namespace}-${var.tfenv}-teleport-cluster-events"
  path        = "/${var.app_name}/${var.app_namespace}/${var.tfenv}/"
  description = "EKS Policy allowing DynamoDB Access for Teleport State ${var.app_name}-${var.app_namespace}-${var.tfenv}"
  policy      = data.aws_iam_policy_document.cluster_events_storage[0].json
  tags        = var.tags
}

## ----------------------------------
## IAM Policy for S3: Session Recording
## ----------------------------------
data "aws_iam_policy_document" "cluster_s3_recording" {
  count = try(coalesce(var.aws_installations.teleport.cluster, false), false) ? 1 : 0

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
    ## TODO: Restrict resources to cluster-associated only.
    resources = [
      "arn:aws:s3:::/${var.app_name}-${var.app_namespace}-${var.tfenv}-teleport-cluster-session-recordings",
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
    ## TODO: Restrict resources to cluster-associated only.
    resources = [
      "arn:aws:s3:::/${var.app_name}-${var.app_namespace}-${var.tfenv}-teleport-cluster-session-recordings/*",
    ]
  }
}

resource "aws_iam_policy" "cluster_s3_recording" {
  count = try(coalesce(var.aws_installations.teleport.cluster, false), false) ? 1 : 0

  name        = "${var.app_name}-${var.app_namespace}-${var.tfenv}-teleport-s3-recordings"
  path        = "/${var.app_name}/${var.app_namespace}/${var.tfenv}/"
  description = "EKS Policy allowing S3 Access for Teleport Recordings ${var.app_name}-${var.app_namespace}-${var.tfenv}"
  policy      = data.aws_iam_policy_document.cluster_s3_recording[0].json
  tags        = var.tags
}

## ----------------------------------
## IAM Role for teleport-cluster
## ----------------------------------
module "teleport_cluster_irsa_role" {
  count = try(coalesce(var.aws_installations.teleport.cluster, false), false) ? 1 : 0

  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.17"

  role_name = "${var.app_name}-${var.app_namespace}-${var.tfenv}-teleport-cluster-role"
  role_path = "/${var.app_name}/${var.app_namespace}/${var.tfenv}/"

  oidc_providers = {
    main = {
      provider_arn               = var.oidc_provider_arn
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
  count = try(coalesce(var.aws_installations.teleport.cluster_discovery, false), false) ? 1 : 0

  statement {
    sid    = "AutomatedClusterDiscovery"
    effect = "Allow"
    actions = [
      "eks:DescribeCluster",
      "eks:ListClusters"
    ]
    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "cluster_discovery" {
  count       = try(coalesce(var.aws_installations.teleport.cluster_discovery, false), false) ? 1 : 0

  name        = "${var.app_name}-${var.app_namespace}-${var.tfenv}-teleport-eks-discovery"
  path        = "/${var.app_name}/${var.app_namespace}/${var.tfenv}/"
  description = "EKS Policy to discover clusters automatically ${var.app_name}-${var.app_namespace}-${var.tfenv}"
  policy      = data.aws_iam_policy_document.cluster_discovery[0].json
  tags        = var.tags
}

## ----------------------------------
## IAM Policy for teleport-rds-auto-discovery
## ----------------------------------
data "aws_iam_policy_document" "rds_discovery" {
  count = try(coalesce(var.aws_installations.teleport.rds_discovery, false), false) ? 1 : 0

  statement {
    sid       = "AutomatedRdsDiscovery"
    effect    = "Allow"
    actions   = [
      "rds:DescribeDBInstances",
      "rds:ModifyDBInstance"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    sid       = "AllowPolicyForIamUser"
    effect    = "Allow"
    actions   = [
      "iam:GetRolePolicy",
      "iam:PutRolePolicy",
      "iam:DeleteRolePolicy"   
    ]
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/*"
    ]
  }

  statement {
    sid       = "AllowIamUserConnectRds"
    effect    = "Allow"
    actions   = ["rds-db:connect"]
    resources = ["arn:aws:rds-db:${var.aws_region}:${data.aws_caller_identity.current.account_id}:dbuser:*/*"]
  }
}

resource "aws_iam_policy" "rds_discovery" {
  count       = try(coalesce(var.aws_installations.teleport.rds_discovery, false), false) ? 1 : 0

  name        = "${var.app_name}-${var.app_namespace}-${var.tfenv}-teleport-rds-discovery"
  path        = "/${var.app_name}/${var.app_namespace}/${var.tfenv}/"
  description = "EKS Policy to discover rds automatically ${var.app_name}-${var.app_namespace}-${var.tfenv}"
  policy      = data.aws_iam_policy_document.rds_discovery[0].json
  tags        = var.tags
}


## ----------------------------------
## IAM Policy for teleport-rds-proxy-auto-discovery
## ----------------------------------
data "aws_iam_policy_document" "rds_proxy_discovery" {
  count = try(coalesce(var.aws_installations.teleport.rds_proxy_discovery, false), false) ? 1 : 0

  statement {
    sid       = "AutomatedRdsProxyDiscovery"
    effect    = "Allow"
    actions   = [
      "rds:DescribeDBProxies",
      "rds:DescribeDBProxyEndpoints",
      "rds:DescribeDBProxyTargets",
      "rds:ListTagsForResource"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    sid       = "AllowPolicyForIamUser"
    effect    = "Allow"
    actions   = [
      "iam:GetRolePolicy",
      "iam:PutRolePolicy",
      "iam:DeleteRolePolicy"   
    ]
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/*"
    ]
  }
}

resource "aws_iam_policy" "rds_proxy_discovery" {
  count       = try(coalesce(var.aws_installations.teleport.rds_proxy_discovery, false), false) ? 1 : 0

  name        = "${var.app_name}-${var.app_namespace}-${var.tfenv}-teleport-rds-proxy-discovery"
  path        = "/${var.app_name}/${var.app_namespace}/${var.tfenv}/"
  description = "EKS Policy to discover rds proxy automatically ${var.app_name}-${var.app_namespace}-${var.tfenv}"
  policy      = data.aws_iam_policy_document.rds_proxy_discovery[0].json
  tags        = var.tags
}

## ----------------------------------
## IAM Role for teleport-kube-agent
## ----------------------------------
module "teleport_kube_agent_irsa_role" {
  count   = try(coalesce(var.aws_installations.teleport.kube_agent, false), false) ? 1 : 0

  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.17"

  role_name = "${var.app_name}-${var.app_namespace}-${var.tfenv}-teleport-kube-agent-role"
  role_path = "/${var.app_name}/${var.app_namespace}/${var.tfenv}/"

  oidc_providers = {
    main = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["teleport:teleport-kube-agent"]
    }
  }
}

resource "aws_iam_policy_attachment" "teleport_kube_agent_cluster_discovery" {
  count      = try(coalesce(var.aws_installations.teleport.cluster_discovery, false), false) ? 1 : 0
  name       = "cluster_discovery"
  roles      = ["${module.teleport_kube_agent_irsa_role[0].iam_role_name}"]
  policy_arn = aws_iam_policy.cluster_discovery[0].arn
} 

resource "aws_iam_policy_attachment" "teleport_kube_agent_rds_discovery" {
  count      = try(coalesce(var.aws_installations.teleport.rds_discovery, false), false) ? 1 : 0
  name       = "rds_discovery"
  roles      = ["${module.teleport_kube_agent_irsa_role[0].iam_role_name}"]
  policy_arn = aws_iam_policy.rds_discovery[0].arn
}

resource "aws_iam_policy_attachment" "teleport_kube_agent_rds_proxy_discovery" {
  count      = try(coalesce(var.aws_installations.teleport.rds_proxy_discovery, false), false) ? 1 : 0
  name       = "rds_proxy_discovery"
  roles      = ["${module.teleport_kube_agent_irsa_role[0].iam_role_name}"]
  policy_arn = aws_iam_policy.rds_proxy_discovery[0].arn
} 
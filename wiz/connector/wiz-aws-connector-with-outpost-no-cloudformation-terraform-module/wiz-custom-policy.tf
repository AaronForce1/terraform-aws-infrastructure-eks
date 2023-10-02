resource "aws_iam_role_policy" "wiz_access_policy" {
  name = "WizAccessPolicy"
  role = aws_iam_role.wiz_access_role-tf.id

  policy = jsonencode({
    "Statement" : [
      {
        "Action" : [
          "acm:GetCertificate",
          "apigateway:GET",
          "backup:DescribeGlobalSettings",
          "backup:GetBackupVaultAccessPolicy",
          "backup:GetBackupVaultNotifications",
          "backup:ListBackupVaults",
          "backup:ListTags",
          "cloudtrail:GetInsightSelectors",
          "cloudtrail:ListTrails",
          "codebuild:BatchGetProjects",
          "codebuild:GetResourcePolicy",
          "codebuild:ListProjects",
          "cognito-identity:DescribeIdentityPool",
          "connect:ListInstances",
          "connect:ListInstanceAttributes",
          "connect:ListInstanceStorageConfigs",
          "connect:ListSecurityKeys",
          "connect:ListLexBots",
          "connect:ListLambdaFunctions",
          "connect:ListApprovedOrigins",
          "connect:ListIntegrationAssociations",
          "dynamodb:DescribeExport",
          "dynamodb:DescribeKinesisStreamingDestination",
          "dynamodb:ListExports",
          "ec2:GetEbsEncryptionByDefault",
          "ec2:SearchTransitGatewayRoutes",
          "ecr:BatchGetImage",
          "ecr:GetAuthorizationToken",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetRegistryPolicy",
          "ecr:DescribeRegistry",
          "ecr-public:ListTagsForResource",
          "eks:ListTagsForResource",
          "elasticfilesystem:DescribeAccessPoints",
          "elasticfilesystem:DescribeFileSystemPolicy",
          "elasticmapreduce:GetAutoTerminationPolicy",
          "elasticmapreduce:GetManagedScalingPolicy",
          "emr-serverless:ListApplications",
          "emr-serverless:ListJobRuns",
          "ssm:GetDocument",
          "ssm:GetServiceSetting",
          "glacier:GetDataRetrievalPolicy",
          "glacier:GetVaultLock",
          "glue:GetConnection",
          "glue:GetSecurityConfiguration",
          "glue:GetTags",
          "health:DescribeAffectedAccountsForOrganization",
          "health:DescribeAffectedEntities",
          "health:DescribeAffectedEntitiesForOrganization",
          "health:DescribeEntityAggregates",
          "health:DescribeEventAggregates",
          "health:DescribeEventDetails",
          "health:DescribeEventDetailsForOrganization",
          "health:DescribeEventTypes",
          "health:DescribeEvents",
          "health:DescribeEventsForOrganization",
          "health:DescribeHealthServiceStatusForOrganization",
          "kafka:ListClusters",
          "kendra:DescribeDataSource",
          "kendra:DescribeIndex",
          "kendra:ListDataSources",
          "kendra:ListIndices",
          "kendra:ListTagsForResource",
          "kinesisanalytics:DescribeApplication",
          "kinesisanalytics:ListApplications",
          "kinesisanalytics:ListTagsForResource",
          "kinesisvideo:GetDataEndpoint",
          "kinesisvideo:ListStreams",
          "kinesisvideo:ListTagsForStream",
          "kms:GetKeyRotationStatus",
          "kms:ListResourceTags",
          "lambda:GetFunction",
          "lambda:GetLayerVersion",
          "macie2:ListFindings",
          "macie2:GetFindings",
          "profile:GetDomain",
          "profile:ListDomains",
          "profile:ListIntegrations",
          "s3:GetBucketNotification",
          "s3:GetMultiRegionAccessPointPolicy",
          "s3:ListMultiRegionAccessPoints",
          "ses:DescribeActiveReceiptRuleSet",
          "ses:GetAccount",
          "ses:GetConfigurationSet",
          "ses:GetConfigurationSetEventDestinations",
          "ses:GetDedicatedIps",
          "ses:GetEmailIdentity",
          "ses:ListConfigurationSets",
          "ses:ListDedicatedIpPools",
          "ses:ListReceiptFilters",
          "voiceid:DescribeDomain",
          "wafv2:GetLoggingConfiguration",
          "wafv2:GetWebACLForResource",
          "wisdom:GetAssistant",
          "cloudwatch:GetMetricStatistics"
        ],
        "Effect" : "Allow",
        "Resource" : "*"
      },
      {
        "Action" : [
          "s3:GetObject",
          "s3:GetBucketLocation",
          "s3:GetObjectTagging",
          "s3:ListBucket"
        ],
        "Effect" : "Allow",
        "Resource" : [
          "arn:aws:s3:::*terraform*",
          "arn:aws:s3:::*tfstate*",
          "arn:aws:s3:::*tf?state*",
          "arn:aws:s3:::*cloudtrail*",
          "arn:aws:s3:::elasticbeanstalk-*"
        ],
        "Sid" : "WizAccessS3"
      }
    ]
    "Version" : "2012-10-17"
    }
  )
}

resource "aws_iam_role_policy" "wiz_scanner_policy" {
  name = "WizScannerPolicy"
  role = aws_iam_role.wiz_scanner_role-tf.id

  policy = jsonencode({
    "Statement" : [
      {
        "Action" : [
          "ec2:CopySnapshot",
          "ec2:CreateSnapshot",
          "ec2:DescribeSnapshots",
          "ec2:GetEbsEncryptionByDefault",
          "ecr:BatchGetImage",
          "ecr:DescribeImages",
          "ecr:GetAuthorizationToken",
          "ecr:GetDownloadUrlForLayer",
          "ecr:ListTagsForResource",
          "ecr:GetRegistryPolicy",
          "ecr:DescribeRegistry",
          "ecr-public:DescribeImages",
          "ecr-public:GetAuthorizationToken",
          "ecr-public:ListTagsForResource",
          "kms:CreateKey",
          "kms:DescribeKey",
        ],
        "Resource" : "*",
        "Effect" : "Allow"
      },
      {
        "Action" : [
          "ec2:CreateTags"
        ],
        "Resource" : "arn:aws:ec2:*::snapshot/*",
        "Effect" : "Allow"
      },
      {
        "Action" : "kms:CreateAlias",
        "Resource" : [
          "arn:aws:kms:*:*:alias/wizKey",
          "arn:aws:kms:*:*:key/*"
        ],
        "Effect" : "Allow"
      },
      {
        "Condition" : {
          "StringLike" : {
            "kms:ViaService" : "ec2.*.amazonaws.com"
          }
        },
        "Action" : [
          "kms:CreateGrant",
          "kms:ReEncryptFrom"
        ],
        "Resource" : "*",
        "Effect" : "Allow"
      },
      {
        "Condition" : {
          "StringEquals" : {
            "aws:ResourceTag/wiz" : "auto-gen-cmk"
          }
        },
        "Action" : [
          "kms:GetKeyPolicy",
          "kms:PutKeyPolicy"
        ],
        "Resource" : "*",
        "Effect" : "Allow"
      },
      {
        "Condition" : {
          "StringEquals" : {
            "ec2:ResourceTag/wiz" : "auto-gen-snapshot"
          }
        },
        "Action" : [
          "ec2:DeleteSnapshot",
          "ec2:ModifySnapshotAttribute"
        ],
        "Resource" : "*",
        "Effect" : "Allow"
      }
    ]
    "Version" : "2012-10-17"
    }
  )
}

resource "aws_iam_role_policy" "wiz_scanner_policy_data" {
  name  = "WizDataScanningPolicy"
  role  = aws_iam_role.wiz_scanner_role-tf.id
  count = var.data-scanning ? 1 : 0
  policy = jsonencode({
    "Statement" : [
      {
        "Action" : [
          "redshift:DeleteClusterSnapshot",
          "redshift:AuthorizeSnapshotAccess",
          "redshift:RevokeSnapshotAccess"
        ],
        "Condition" : {
          "StringEquals" : {
            "aws:ResourceTag/wiz" : "auto-gen-snapshot"
          }
        },
        "Effect" : "Allow",
        "Resource" : "*"
      },
      {
        "Action" : [
          "redshift:CreateTags"
        ],
        "Effect" : "Allow",
        "Resource" : "arn:aws:redshift:*:*:snapshot:*/*"
      },
      {
        "Action" : [
          "redshift:DescribeClusterSnapshots",
          "redshift:DescribeClusters"
        ],
        "Effect" : "Allow",
        "Resource" : "*"
      },
      {
        "Action" : [
          "redshift:CreateClusterSnapshot"
        ],
        "Condition" : {
          "StringEquals" : {
            "aws:RequestTag/wiz" : "auto-gen-snapshot"
          }
        },
        "Effect" : "Allow",
        "Resource" : "*"
      },
      {
        "Action" : [
          "rds:DescribeDBClusters",
          "rds:DescribeDBClusterSnapshots",
          "rds:DescribeDBInstances",
          "rds:DescribeDBSnapshots",
          "rds:DescribeDBSubnetGroups",
          "rds:ListTagsForResource",
          "rds:AddTagsToResource"
        ],
        "Effect" : "Allow",
        "Resource" : "*"
      },
      {
        "Action" : [
          "rds:DeleteDBClusterSnapshot",
          "rds:ModifyDBClusterSnapshotAttribute"
        ],
        "Effect" : "Allow",
        "Resource" : "arn:aws:rds:*:*:cluster-snapshot:wiz-autogen-*"
      },
      {
        "Action" : [
          "rds:DeleteDBSnapshot",
          "rds:ModifyDBSnapshotAttribute"
        ],
        "Effect" : "Allow",
        "Resource" : "arn:aws:rds:*:*:snapshot:wiz-autogen-*"
      },
      {
        "Action" : [
          "rds:CopyDBClusterSnapshot",
          "rds:CopyDBSnapshot"
        ],
        "Effect" : "Allow",
        "Resource" : "*"
      },
      {
        "Action" : [
          "rds:CreateDBClusterSnapshot",
          "rds:CreateDBSnapshot"
        ],
        "Condition" : {
          "StringEquals" : {
            "rds:req-tag/wiz" : "auto-gen-snapshot"
          }
        },
        "Effect" : "Allow",
        "Resource" : "*"
      },
      {
        "Action" : [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        "Effect" : "Allow",
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "kms:CreateGrant",
          "kms:ReEncrypt*"
        ],
        "Resource" : "*",
        "Condition" : {
          "StringLike" : {
            "kms:ViaService" : "rds.*.amazonaws.com"
          }
        }
      }
    ]
    "Version" : "2012-10-17"
  })
}

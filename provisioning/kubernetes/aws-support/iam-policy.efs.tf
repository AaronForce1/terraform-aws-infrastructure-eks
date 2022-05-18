resource "aws_iam_policy" "amazoneks-efs-csi-driver-policy" {
  name        = "${var.app_name}-${var.app_namespace}-${var.tfenv}-AmazonEKS-EFS_CSI_Driver-policy"
  path        = "/"
  description = "EKS EFS CSI Driver policy for cluster ${var.app_name}-${var.app_namespace}-${var.tfenv}"
  policy      = data.aws_iam_policy_document.efs_csi_driver.json
  tags        = var.tags
}

resource "aws_iam_role" "amazoneks-efs-csi-driver-role" {
  name               = "${var.app_name}-${var.app_namespace}-${var.tfenv}-AmazonEKS-EFS_CSI_Driver-role"
  assume_role_policy = data.aws_iam_policy_document.eks_efs_csi_driver_trust_policy.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "eks-efs-csi-driver-attachment" {
  role       = aws_iam_role.amazoneks-efs-csi-driver-role.name
  policy_arn = aws_iam_policy.amazoneks-efs-csi-driver-policy.arn
}

data "aws_iam_policy_document" "efs_csi_driver" {
  statement {
    effect = "Allow"
    actions = [
      "elasticfilesystem:DescribeAccessPoints",
      "elasticfilesystem:DescribeFileSystems"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "elasticfilesystem:CreateAccessPoint"
    ]
    resources = ["*"]
    condition {
      test     = "StringLike"
      variable = "aws:RequestTag/efs.csi.aws.com/cluster"
      values   = ["true"]
    }
  }

  statement {
    effect = "Allow"
    actions = [
      "elasticfilesystem:DeleteAccessPoint"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/efs.csi.aws.com/cluster"
      values   = ["true"]
    }
  }
}


data "aws_iam_policy_document" "eks_efs_csi_driver_trust_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.aws-support.account_id}:oidc-provider/oidc.eks.${var.aws_region}.amazonaws.com/id/${substr(var.oidc_url, -32, -1)}"]
    }
    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]
    condition {
      test     = "StringEquals"
      variable = "oidc.eks.${var.aws_region}.amazonaws.com/id/${substr(var.oidc_url, -32, -1)}:sub"
      values   = ["system:serviceaccount:kube-system:efs-csi-controller-sa"]
    }
  }
}

resource "kubernetes_storage_class" "efs-storage-class" {
  metadata {
    name = "efs"
  }
  storage_provisioner = "efs.csi.aws.com"
}

resource "aws_security_group" "efs-driver" {
  name = "efs-csi-driver-sg"
  description = "Allow EFS inbound traffic"
  vpc_id      = module.eks-vpc.vpc_id 
  
  ingress {
    description = "Allow EFS Traffic on Private Subnets"
    from_port = 2049
    to_port = 2049
    protocol = "tcp"
    cidr_blocks = [module.eks-vpc.private_subnets_cidr_blocks]
  }
  
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

}


resource "aws_iam_policy" "eks-efs-csi-driver-policy" {
  name =  "AmazonEKS_EFS_CSI_Driver_Policy"
  path = "/"
  description = "Policy for EKS EFS CSI Driver"
  policy = jsonencode ({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "elasticfilesystem:DescribeAccessPoints",
          "elasticfilesystem:DescribeFileSystems"
        ]
        Effect = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "elasticfilesystem:CreateAccessPoint"
        ]
        Effect = "Allow"
        Resource = "*"
        Condition = {
          StringLike = {
            "aws:RequestTag/efs.csi.aws.com/cluster": "true"
          }
        } 
      },
      {
        Action = [
          "elasticfilesystem:DeleteAccessPoint"
        ]
        Effect = "Allow"
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:ResourceTag/efs.csi.aws.com/cluster": "true"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role" "eks-efs-csi-driver-role" {
  name = "AmazonEKS_EFS_CSI_DriverRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Condition = {
          StringEquals = {
            "oidc.eks.${var.aws_region}.amazonaws.com/id/${module.eks.cluster_oidc_issuer_url}:sub": "system:serviceaccount:kube-system:ebs-csi-controller-sa"
          }
        }
        Principal = {
          "Federated": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/oidc.eks.${var.aws_region}.amazonaws.com/id/${module.eks.cluster_oidc_issuer_url}"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach-eks-efs-csi-driver-policy" {
  role = aws_iam_role.eks-efs-csi-driver-role.name
  policy_arn = aws_iam_policy.eks-efs-csi-driver-policy.arn
}
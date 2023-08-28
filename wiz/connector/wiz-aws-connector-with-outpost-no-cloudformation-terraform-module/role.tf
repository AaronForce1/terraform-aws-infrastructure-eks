resource "aws_iam_role" "wiz_access_role-tf" {
  name = var.wiz_access_rolename
  tags = var.tags
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Principal" : {
            "AWS" : var.remote-arn
          },
          "Action" : "sts:AssumeRole",
          "Condition" : {
            "StringEquals" : {
              "sts:ExternalId" : var.external-id
            }
          }
        }
      ]
    }
  )
}

resource "aws_iam_role" "wiz_scanner_role-tf" {
  name = var.wiz_scanner_rolename
  tags = var.tags
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Principal" : {
            "AWS" : var.outpost-remote-arn
          },
          "Action" : "sts:AssumeRole",
          "Condition" : {
            "StringEquals" : {
              "sts:ExternalId" : var.external-id
            }
          }
        }
      ]
    }
  )
}

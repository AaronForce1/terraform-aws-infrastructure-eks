### AWS policy ARN for existing service role

data "aws_iam_policy" "view_only_access" {
  arn = "arn:aws:iam::aws:policy/job-function/ViewOnlyAccess"
}

data "aws_iam_policy" "security_audit" {
  arn = "arn:aws:iam::aws:policy/SecurityAudit"
}

### Policy attachment

resource "aws_iam_role_policy_attachment" "view_only_access_role_policy_attach" {
  role       = aws_iam_role.wiz_access_role-tf.name
  policy_arn = data.aws_iam_policy.view_only_access.arn
}

resource "aws_iam_role_policy_attachment" "security_audit_role_policy_attach" {
  role       = aws_iam_role.wiz_access_role-tf.name
  policy_arn = data.aws_iam_policy.security_audit.arn
}

resource "aws_iam_role_policy_attachment" "view_only_scanner_role_policy_attach" {
  role       = aws_iam_role.wiz_scanner_role-tf.name
  policy_arn = data.aws_iam_policy.view_only_access.arn
}

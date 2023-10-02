module "wiz_aws_outpost_connector" {
  source = "s3::https://s3-us-east-2.amazonaws.com/wizio-public/deployment-v2/aws/wiz-aws-connector-with-outpost-no-cloudformation-terraform-module.zip"
  external-id = "CopyandPastefromtheWizConsole"
  outpost-remote-arn = "arn:aws:iam::OUTPOSTACCOUNTID:root"
  data-scanning = "true"
  wiz_access_rolename = "WizAccess-Role"
  wiz_scanner_rolename = "WizScanner-Role"
  tags = {}
}

output "wiz_access_role_arn" {
  value = module.wiz_aws_outpost_connector.wiz_access_role_arn
}

output "wiz_scanner_role_arn" {
  value = module.wiz_aws_outpost_connector.wiz_scanner_role_arn
}


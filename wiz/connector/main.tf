variable "wiz_aws_outpost_connector" {
  type = any
}
module "wiz_aws_outpost_connector" {
  source = "./wiz-aws-connector-with-outpost-no-cloudformation-terraform-module"

  external-id          = lookup(var.wiz_aws_outpost_connector, "external-id", "")
  outpost-remote-arn   = lookup(var.wiz_aws_outpost_connector, "outpost-remote-arn", "arn:aws:iam::790803523705:root")
  remote-arn           = lookup(var.wiz_aws_outpost_connector, "remote-arn", "arn:aws:iam::830522659852:root")
  data-scanning        = lookup(var.wiz_aws_outpost_connector, "data-scanning", true)
  wiz_access_rolename  = lookup(var.wiz_aws_outpost_connector, "wiz_access_rolename", "WizAccess-Outpost-Role")
  wiz_scanner_rolename = lookup(var.wiz_aws_outpost_connector, "wiz_scanner_rolename", "WizScannerRole-Outpost")
  tags = lookup(var.wiz_aws_outpost_connector, "tags", {
    Billing = "Security"
  })
}

output "wiz_access_role_arn" {
  value = module.wiz_aws_outpost_connector.wiz_access_role_arn
}

output "wiz_scanner_role_arn" {
  value = module.wiz_aws_outpost_connector.wiz_scanner_role_arn
}

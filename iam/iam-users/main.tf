module "iam-user" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-user"
  version = "5.30.0"

  for_each = var.iam-user
  name     = try(each.value.role_name, "${var.app_name}-${var.app_namespace}-${var.tfenv}-${try(each.value.name, each.key)}")

  create_iam_access_key         = try(each.value.create_iam_access_key, true)
  create_iam_user_login_profile = try(each.value.create_iam_user_login_profile, false)
  create_user                   = try(each.value.create_user, true)
  policy_arns                   = try(each.value.policy_arns, [])
}
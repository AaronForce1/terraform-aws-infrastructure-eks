module "ssm-parameter" {
  source  = "terraform-aws-modules/ssm-parameter/aws"
  version = "1.0.1"
  for_each = var.parameters

  name            = try(each.value.name, each.key)
  value           = try(each.value.value, null)
  values          = try(each.value.values, [])
  type            = try(each.value.type, null)
  secure_type     = try(each.value.secure_type, true)
  description     = try(each.value.description, null)
  tier            = try(each.value.tier, "Standard")
  overwrite       = try(each.value.overwrite, true)
  key_id          = try(each.value.key_id, null)
  allowed_pattern = try(each.value.allowed_pattern, null)
  data_type       = try(each.value.data_type, null)

  tags = try(each.value.tags, {})
}

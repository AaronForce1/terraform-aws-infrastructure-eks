resource "kubectl_manifest" "teleport-dev-role-binding" {
  # for_each = {
  #   for role in var.kubernetes_access_controls : role.value_file => role
  # }
  
  count = var.kubernetes_access_controls  != null ? length(flatten(var.kubernetes_access_controls.*.value_file)) : 0
  yaml_body = var.kubernetes_access_controls[count.index].value_file
}
### ACCESS_RULES
resource "cloudflare_access_rule" "access_rule" {
  for_each = { for rule in var.access_rules : rule.notes => rule }

  zone_id = var.zone_id
  notes   = each.value.notes
  mode    = each.value.mode

  configuration {
    target = each.value.target
    value  = each.value.value
  }
}

### CUSTOM_RULES
resource "cloudflare_ruleset" "zone_custom_firewall" {
  zone_id     = var.zone_id
  name        = "Phase entry point ruleset for custom rules in ${var.zone_domain}"
  description = ""
  kind        = "zone"
  phase       = "http_request_firewall_custom"

  dynamic "rules" {
    for_each = var.custom_rules
    content {
      action      = rules.value.action
      expression  = rules.value.expression
      description = rules.value.description
      enabled     = rules.value.enabled
    }
  }
}

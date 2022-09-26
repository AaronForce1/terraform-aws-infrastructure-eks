plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

rule "terraform_typed_variables" {
  enabled = false
}

rule "terraform_required_providers" {
  enabled = false
}

rule "terraform_required_version" {
  enabled = false
}
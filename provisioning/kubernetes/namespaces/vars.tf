variable "helm_installations" {
  type = object({
    vault_consul = bool
    ingress      = bool
  })
}
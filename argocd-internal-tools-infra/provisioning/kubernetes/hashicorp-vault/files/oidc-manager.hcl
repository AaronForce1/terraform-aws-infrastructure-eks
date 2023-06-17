path "sys/auth/oidc" {
    capabilities = [ "create", "read", "update", "delete", "sudo" ]
}

path "auth/oidc/*" {
    capabilities = [ "create", "read", "update", "delete", "list" ]
}

path "sys/policies/acl/*" {
    capabilities = [ "create", "read", "update", "delete", "list" ]
}

path "sys/mounts" {
    capabilities = [ "read" ]
}
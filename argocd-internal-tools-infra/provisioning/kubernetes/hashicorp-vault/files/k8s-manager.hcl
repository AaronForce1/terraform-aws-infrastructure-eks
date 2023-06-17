path "sys/auth/kubernetes" {
    capabilities = [ "create", "read", "update", "delete", "sudo" ]
}

path "auth/kubernetes/*" {
    capabilities = [ "create", "read", "update", "delete", "list" ]
}
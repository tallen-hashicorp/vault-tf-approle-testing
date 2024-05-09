# Allow full access to the KV version 2 secrets engine
path "kv/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# Allow access to list the metadata of the KV version 2 secrets engine
path "kv/metadata/*" {
  capabilities = ["list"]
}

## Allow the creation of tokens
path "auth/token/create" {
  capabilities = ["create", "update"]
}
# Developers can read and set all secrets
path "secret/userland" {
  capabilities = ["read", "list"]
}

path "secret/fabio/certs/${api_domain}" {
  capabilities = ["read"]
}

path "secret/fabio/certs/" {
  capabilities = ["list"]
}

path "secret/fabio/certs/*" {
  capabilities = ["read"]
}

path "secret/infra" {
  capabilities = ["read"]
}

# The following capabilities are typically provided by Vault's default policy.
path "auth/token/lookup-self" {
    capabilities = ["read"]
}
path "auth/token/renew-self" {
    capabilities = ["update"]
}

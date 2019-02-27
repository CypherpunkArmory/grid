# Allow the city-host IAM profile to fetch a nomad-server token
path "auth/token/create/nomad-server" {
  capabilities = [ "update" ]
}

# Allow checking the capabilities of our own token. This is used to validate the
# token upon startup.
path "sys/capabilities-self" {
  capabilities = ["update"]
}

# Allow our own token to be renewed.
path "auth/token/renew-self" {
  capabilities = ["update"]
}


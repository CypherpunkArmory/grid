storage "dynamodb" {
  ha_enabled = "false"
  table      = "vault-secrets-{{ env }}"
  region     = "us-west-2"
}

ui = true

listener "tcp" {
  address     = "127.0.0.1:8200"
  tls_disable = 1
}

seal "awskms" {
  region = "us-west-2"
  kms_key_id = "{{ key_id }}"
}

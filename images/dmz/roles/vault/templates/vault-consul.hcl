service {
  name = "vault"
  tags = ["city", "vault"]
  port = 8200
  checks = [
    {
      id = "vault"
      name = "Vault API in port 8200"
      http = "http://127.0.0.1:8200"
      interval = "10s"
    }
  ]
}

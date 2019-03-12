resource "aws_dynamodb_table" "vault-secrets" {
  name           = "vault-secrets-${terraform.workspace}"

  read_capacity  = 5
  write_capacity = 5

  hash_key       = "Path"
  range_key      = "Key"

  attribute {
    name = "Path"
    type = "S"
  }

  attribute {
    name = "Key"
    type = "S"
  }

  tags {
    District    = "city"
    Usage       = "infra"
    Name        = "city_vault"
    Role        = "db"
    Environment = "${terraform.workspace}"
  }
}

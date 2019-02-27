resource "aws_dynamodb_table" "vault-secrets" {
  name           = "vault-secrets-${var.environment}"

  read_capacity  = 1
  write_capacity = 1

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
    Name        = "vault-dynamodb-table"
    Environment = "${var.environment}"
    District    = "city"
  }
}

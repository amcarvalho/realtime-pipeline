resource "aws_dynamodb_table" "user_table" {
  name = "user_table"
  billing_mode = "PAY_PER_REQUEST"
  read_capacity = 5
  write_capacity = 5
  hash_key = "user_id"

  attribute {
    name = "user_id"
    type = "S"
  }
}
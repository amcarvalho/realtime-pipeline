locals {
  user_consumer_zip_location = "outputs/user-consumer.zip"
}

data "archive_file" "user_consumer" {
  type        = "zip"
  source_file = "${path.module}/lambda-source/user-consumer.py"
  output_path = local.user_consumer_zip_location
}

resource "aws_lambda_function" "user_consumer" {
  filename      = local.user_consumer_zip_location
  function_name = "user_consumer"
  role          = var.lambda_user_consumer_role_arn
  handler       = "user-consumer.user_consumer"
  source_code_hash = filebase64sha256(local.user_consumer_zip_location)
  runtime = "python3.7"
}

resource "aws_lambda_event_source_mapping" "lambda_user_consumer_event_source" {
  event_source_arn  = var.user_stream_arn
  function_name     = aws_lambda_function.user_consumer.arn
  starting_position = "LATEST"
}
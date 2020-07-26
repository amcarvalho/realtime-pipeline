locals {
  pageviews_consumer_zip_location = "outputs/pageview-consumer.zip"
}

data "archive_file" "pageviews_consumer" {
  type        = "zip"
  source_file = "${path.module}/lambda-source/pageview-consumer.py"
  output_path = local.pageviews_consumer_zip_location
}

resource "aws_lambda_function" "pageviews_consumer" {
  filename      = local.pageviews_consumer_zip_location
  function_name = "pageviews_consumer"
  role          = var.lambda_pageviews_consumer_role_arn
  handler       = "pageview-consumer.pageviews_consumer"
  source_code_hash = filebase64sha256(local.pageviews_consumer_zip_location)
  runtime = "python3.7"
}

resource "aws_lambda_event_source_mapping" "lambda_pageviews_consumer_event_source" {
  event_source_arn  = var.pageviews_stream_arn
  function_name     = aws_lambda_function.pageviews_consumer.arn
  starting_position = "LATEST"
}
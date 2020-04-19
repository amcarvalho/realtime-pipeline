locals {
  pageview_consumer_zip_location = "outputs/pageview-consumer.zip"
}

data "archive_file" "pageview_consumer" {
  type        = "zip"
  source_file = "${path.module}/lambda-source/pageview-consumer.py"
  output_path = local.pageview_consumer_zip_location
}

resource "aws_lambda_function" "pageview_consumer" {
  filename      = local.pageview_consumer_zip_location
  function_name = "pageview_consumer"
  role          = aws_iam_role.lambda_pageview_consumer_role.arn
  handler       = "pageview-consumer.pageview_consumer"
  source_code_hash = filebase64sha256(local.pageview_consumer_zip_location)
  runtime = "python3.7"
}

resource "aws_lambda_event_source_mapping" "lambda_pageview_consumer_event_source" {
  event_source_arn  = var.pageview_stream_arn
  function_name     = aws_lambda_function.pageview_consumer.arn
  starting_position = "LATEST"
}

resource "aws_iam_role_policy" "lambda_pageview_consumer_policy" {
  name = "lambda_pageview_consumer_policy"
  role = aws_iam_role.lambda_pageview_consumer_role.id
  policy = data.aws_iam_policy_document.lambda_pageview_consumer_policy_document.json
}

resource "aws_iam_role" "lambda_pageview_consumer_role" {
  name = "lambda_pageview_consumer_role"
  assume_role_policy = data.aws_iam_policy_document.lambda_pageview_consumer_assume_role_policy_document.json
}

data "aws_iam_policy_document" "lambda_pageview_consumer_assume_role_policy_document" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["lambda.amazonaws.com"]
      type = "Service"
    }
    effect = "Allow"
    sid = ""
  }
}

data "aws_iam_policy_document" "lambda_pageview_consumer_policy_document" {
  statement {
    actions = ["logs:*"]
    resources = ["*"]
  }

  statement {
    actions = [
      "kinesis:Get*",
      "kinesis:DescribeStream"
    ]
    resources = [var.pageview_stream_arn]
  }

  statement {
    actions = ["kinesis:ListStreams"]
    resources = ["*"]
    effect = "Allow"
  }

  statement {
    actions = ["kinesis:PutRecord"]
    resources = [var.enriched_pageview_stream_arn]
    effect = "Allow"
  }

  statement {
    actions = ["dynamodb:GetItem"]
    resources = [var.user_table_arn]
    effect = "Allow"
  }
}
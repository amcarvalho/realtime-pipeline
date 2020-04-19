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
  role          = aws_iam_role.lambda_user_consumer_role.arn
  handler       = "user-consumer.user_consumer"
  source_code_hash = filebase64sha256(local.user_consumer_zip_location)
  runtime = "python3.7"
}

resource "aws_lambda_event_source_mapping" "lambda_user_consumer_event_source" {
  event_source_arn  = var.user_stream_arn
  function_name     = aws_lambda_function.user_consumer.arn
  starting_position = "LATEST"
}

resource "aws_iam_role_policy" "lambda_user_consumer_policy" {
  name = "lambda_user_consumer_policy"
  role = aws_iam_role.lambda_user_consumer_role.id
  policy = data.aws_iam_policy_document.lambda_user_consumer_policy_document.json
}

resource "aws_iam_role" "lambda_user_consumer_role" {
  name = "lambda_user_consumer_role"
  assume_role_policy = data.aws_iam_policy_document.lambda_user_consumer_assume_role_policy_document.json
}

data "aws_iam_policy_document" "lambda_user_consumer_assume_role_policy_document" {
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

data "aws_iam_policy_document" "lambda_user_consumer_policy_document" {
  statement {
    actions = ["logs:*"]
    resources = ["*"]
  }

  statement {
    actions = [
      "kinesis:Get*",
      "kinesis:DescribeStream"
    ]
    resources = [var.user_stream_arn]
    effect = "Allow"
  }

  statement {
    actions = ["kinesis:ListStreams"]
    resources = ["*"]
    effect = "Allow"
  }

  statement {
    actions = ["dynamodb:PutItem"]
    resources = [var.user_table_arn]
    effect = "Allow"
  }
}
resource "aws_kinesis_stream" "user_stream" {
  name             = "user_stream"
  shard_count      = 1
  retention_period = 24
}

resource "aws_kinesis_stream" "pageview_stream" {
  name             = "pageview_stream"
  shard_count      = 1
  retention_period = 24
}

resource "aws_kinesis_stream" "enriched_pageview_stream" {
  name             = "enriched_pageview_stream"
  shard_count      = 1
  retention_period = 24
}

resource "aws_kinesis_firehose_delivery_stream" "enriched_pageview_delivery_stream" {
  name        = "enriched_pageview_delivery_stream"
  destination = "s3"

  kinesis_source_configuration {
    kinesis_stream_arn = aws_kinesis_stream.enriched_pageview_stream.arn
    role_arn = aws_iam_role.firehose_role.arn
  }

  s3_configuration {
    bucket_arn = var.enriched_pageview_s3_bucket_arn
    role_arn   = aws_iam_role.firehose_role.arn
    buffer_interval = 60
    buffer_size = 1
    cloudwatch_logging_options {
      enabled = true
      log_group_name = aws_cloudwatch_log_group.enriched_pageview_delivery_stream_log_group.name
      log_stream_name = "S3Delivery"
    }
  }
}

resource "aws_cloudwatch_log_group" "enriched_pageview_delivery_stream_log_group" {
  name = "/aws/kinesisfirehose/enriched_pageview_delivery_stream_log_group"
}

resource "aws_iam_role" "firehose_role" {
  name = "enriched_pageview_delivery_stream_role"
  assume_role_policy = data.aws_iam_policy_document.firehose_role_document.json
}

data "aws_iam_policy_document" "firehose_role_document" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["firehose.amazonaws.com"]
      type = "Service"
    }
    effect = "Allow"
    sid = ""
  }
}

resource "aws_iam_role_policy" "firehose_policy" {
  name = "firehose_policy"
  role = aws_iam_role.firehose_role.id
  policy = data.aws_iam_policy_document.enriched_pageview_stream_consumer_policy_document.json
}

data "aws_iam_policy_document" "enriched_pageview_stream_consumer_policy_document" {
  statement {
    actions = [
      "kinesis:Get*",
      "kinesis:DescribeStream"
    ]
    resources = [aws_kinesis_stream.enriched_pageview_stream.arn]
  }

  statement {
    actions = ["kinesis:ListStreams"]
    resources = ["*"]
    effect = "Allow"
  }

  statement {
    actions = ["logs:*"]
    resources = ["*"]
  }

  statement {
    actions = ["s3:*"]
    resources = [
      var.enriched_pageview_s3_bucket_arn,
      "${var.enriched_pageview_s3_bucket_arn}/*",
    ]
  }
}
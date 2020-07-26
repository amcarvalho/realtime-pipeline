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

resource "aws_iam_role_policy" "lambda_pageviews_consumer_policy" {
  name = "lambda_pageviews_consumer_policy"
  role = aws_iam_role.lambda_pageviews_consumer_role.id
  policy = data.aws_iam_policy_document.lambda_pageviews_consumer_policy_document.json
}

resource "aws_iam_role" "lambda_pageviews_consumer_role" {
  name = "lambda_pageviews_consumer_role"
  assume_role_policy = data.aws_iam_policy_document.lambda_pageviews_consumer_assume_role_policy_document.json
}

data "aws_iam_policy_document" "lambda_pageviews_consumer_assume_role_policy_document" {
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

data "aws_iam_policy_document" "lambda_pageviews_consumer_policy_document" {
  statement {
    actions = ["logs:*"]
    resources = ["*"]
  }

  statement {
    actions = [
      "kinesis:Get*",
      "kinesis:DescribeStream"
    ]
    resources = [var.pageviews_stream_arn]
  }

  statement {
    actions = ["kinesis:ListStreams"]
    resources = ["*"]
    effect = "Allow"
  }

  statement {
    actions = ["kinesis:PutRecord"]
    resources = [var.enriched_pageviews_stream_arn]
    effect = "Allow"
  }

  statement {
    actions = ["dynamodb:GetItem"]
    resources = [var.user_table_arn]
    effect = "Allow"
  }
}

resource "aws_iam_role" "enriched_pageview_firehose_role" {
  name = "enriched_pageviews_delivery_stream_role"
  assume_role_policy = data.aws_iam_policy_document.enriched_pageview_firehose_role_document.json
}

data "aws_iam_policy_document" "enriched_pageview_firehose_role_document" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = [
        "firehose.amazonaws.com",
        "kinesisanalytics.amazonaws.com"
      ]
      type = "Service"
    }
    effect = "Allow"
    sid = ""
  }
}

resource "aws_iam_role_policy" "firehose_policy" {
  name = "firehose_policy"
  role = aws_iam_role.enriched_pageview_firehose_role.id
  policy = data.aws_iam_policy_document.enriched_pageviews_stream_consumer_policy_document.json
}

data "aws_iam_policy_document" "enriched_pageviews_stream_consumer_policy_document" {
  statement {
    actions = [
      "kinesis:Get*",
      "kinesis:DescribeStream"
    ]
    resources = [var.enriched_pageviews_stream_arn]
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
      var.enriched_pageviews_s3_bucket_arn,
      "${var.enriched_pageviews_s3_bucket_arn}/*",
    ]
  }
}

resource "aws_iam_role" "pageviews_count_by_postcode_firehose_role" {
  name = "pageviews_count_by_postcode_firehose_role"
  assume_role_policy = data.aws_iam_policy_document.pageviews_count_by_postcode_firehose_role_document.json
}

data "aws_iam_policy_document" "pageviews_count_by_postcode_firehose_role_document" {
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

resource "aws_iam_role_policy" "pageviews_count_by_postcode_firehose_policy" {
  name = "pageviews_count_by_postcode_firehose_policy"
  role = aws_iam_role.pageviews_count_by_postcode_firehose_role.id
  policy = data.aws_iam_policy_document.pageviews_count_by_postcode_consumer_policy_document.json
}

data "aws_iam_policy_document" "pageviews_count_by_postcode_consumer_policy_document" {
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
      var.pageviews_count_by_postcode_s3_bucket_arn,
      "${var.pageviews_count_by_postcode_s3_bucket_arn}/*",
    ]
  }
}

########## Kinesis Analytics Application Pageview Counts by Postcode ##########
resource "aws_iam_role" "pageviews_count_by_postcode_kinesis_application_role" {
  name = "pageviews_count_by_postcode_kinesis_application_role"
  assume_role_policy = data.aws_iam_policy_document.pageviews_count_by_postcode_kinesis_application_role_document.json
}

data "aws_iam_policy_document" "pageviews_count_by_postcode_kinesis_application_role_document" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["kinesisanalytics.amazonaws.com"]
      type = "Service"
    }
    effect = "Allow"
    sid = ""
  }
}

resource "aws_iam_role_policy" "pageviews_count_by_postcode_kinesis_application_policy" {
  name = "pageviews_count_by_postcode_kinesis_application_policy"
  role = aws_iam_role.pageviews_count_by_postcode_kinesis_application_role.id
  policy = data.aws_iam_policy_document.pageviews_count_by_postcode_kinesis_application_policy_document.json
}

data "aws_iam_policy_document" "pageviews_count_by_postcode_kinesis_application_policy_document" {
   statement {
    sid       = "ReadInputKinesis"
    effect    = "Allow"
    resources = [var.enriched_pageviews_stream_arn]

    actions = [
      "kinesis:DescribeStream",
      "kinesis:GetShardIterator",
      "kinesis:GetRecords",
    ]
  }

  statement {
    sid       = "WriteOutputFirehose"
    effect    = "Allow"
    resources = ["arn:aws:firehose:eu-west-2:218402439852:deliverystream/pageviews_count_by_postcode_delivery_stream"]

    actions = [
      "firehose:DescribeDeliveryStream",
      "firehose:PutRecord",
      "firehose:PutRecordBatch",
    ]
  }
}
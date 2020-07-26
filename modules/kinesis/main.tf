resource "aws_kinesis_stream" "user_stream" {
  name             = "user_stream"
  shard_count      = 1
  retention_period = 24
}

resource "aws_kinesis_stream" "pageviews_stream" {
  name             = "pageviews_stream"
  shard_count      = 1
  retention_period = 24
}

resource "aws_kinesis_stream" "enriched_pageviews_stream" {
  name             = "enriched_pageviews_stream"
  shard_count      = 1
  retention_period = 24
}

## Pageviews Count by Postcode Firehose ##
resource "aws_kinesis_firehose_delivery_stream" "pageviews_count_by_postcode_delivery_stream" {
  name        = "pageviews_count_by_postcode_delivery_stream"
  destination = "s3"

  s3_configuration {
    bucket_arn = var.pageviews_count_by_postcode_s3_bucket_arn
    role_arn   = var.pageviews_count_by_postcode_firehose_role_arn
    buffer_interval = 60
    buffer_size = 1
    cloudwatch_logging_options {
      enabled = true
      log_group_name = aws_cloudwatch_log_group.pageviews_count_by_postcode_delivery_stream_log_group.name
      log_stream_name = "S3Delivery"
    }
  }
}

resource "aws_cloudwatch_log_group" "pageviews_count_by_postcode_delivery_stream_log_group" {
  name = "/aws/kinesisfirehose/pageviews_count_by_postcode_delivery_stream_log_group"
}

## Enriched Pageviews Firehose ##
resource "aws_kinesis_firehose_delivery_stream" "enriched_pageviews_delivery_stream" {
  name        = "enriched_pageviews_delivery_stream"
  destination = "s3"

  kinesis_source_configuration {
    kinesis_stream_arn = aws_kinesis_stream.enriched_pageviews_stream.arn
    role_arn = var.enriched_pageview_firehose_role_arn
  }

  s3_configuration {
    bucket_arn = var.enriched_pageviews_s3_bucket_arn
    role_arn   = var.enriched_pageview_firehose_role_arn
    buffer_interval = 60
    buffer_size = 1
    cloudwatch_logging_options {
      enabled = true
      log_group_name = aws_cloudwatch_log_group.enriched_pageviews_delivery_stream_log_group.name
      log_stream_name = "S3Delivery"
    }
  }
}

resource "aws_cloudwatch_log_group" "enriched_pageviews_delivery_stream_log_group" {
  name = "/aws/kinesisfirehose/enriched_pageviews_delivery_stream_log_group"
}

###################### Pageviews Count by Postcode Application ######################
resource "aws_kinesis_analytics_application" "pageviews_count_by_postcode_application" {
  name = "pageviews_count_by_postcode_application"
  code = "${file("${path.module}/kinesis-analytics-source/pageviews-count-by-postcode.sql")}"

  inputs {
    name_prefix = "SOURCE_SQL_STREAM"

    kinesis_stream {
      resource_arn = aws_kinesis_stream.enriched_pageviews_stream.arn
      role_arn = var.pageviews_count_by_postcode_kinesis_application_role_arn
    }

    schema {
      record_columns {
        mapping = "$.postcode"
        name = "postcode"
        sql_type = "VARCHAR(4)"
      }

      record_columns {
        mapping  = "$.event_datetime"
        name     = "event_datetime"
        sql_type = "TIMESTAMP"
      }

      record_columns {
        mapping  = "$.url"
        name     = "url"
        sql_type = "VARCHAR(6)"
      }

      record_encoding = "UTF-8"

      record_format {
        mapping_parameters {
          json {
            record_row_path = "$"
          }
        }
      }

    }
  }

  outputs {
    name = "DESTINATION_SQL_STREAM"
    schema {
      record_format_type = "JSON"
    }
    kinesis_firehose {
      resource_arn = aws_kinesis_firehose_delivery_stream.pageviews_count_by_postcode_delivery_stream.arn
      role_arn = var.pageviews_count_by_postcode_kinesis_application_role_arn
    }
  }
}
provider "aws" {
  region = "eu-west-2"
}

module "s3" {
  source = "../modules/s3"
}

module "kinesis" {
  source = "../modules/kinesis"
  enriched_pageview_s3_bucket_arn = module.s3.enriched_pageview_s3_bucket_arn
  pageviews_count_by_postcode_s3_bucket_arn = module.s3.pageviews_count_by_postcode_s3_bucket_arn
}

module "dynamodb" {
  source = "../modules/dynamodb"
}

module "lambda" {
  source = "../modules/lambda"
  user_stream_arn = module.kinesis.user_stream_arn
  pageview_stream_arn = module.kinesis.pageview_stream_arn
  enriched_pageview_stream_arn = module.kinesis.enriched_pageview_stream_arn
  user_table_arn = module.dynamodb.user_table_arn
}
provider "aws" {
  region = "eu-west-2"
}

module "iam" {
  source = "../modules/iam"
  enriched_pageviews_s3_bucket_arn = module.s3.enriched_pageviews_s3_bucket_arn
  pageviews_count_by_postcode_s3_bucket_arn = module.s3.pageviews_count_by_postcode_s3_bucket_arn
  user_stream_arn = module.kinesis.user_stream_arn
  pageviews_stream_arn = module.kinesis.pageviews_stream_arn
  enriched_pageviews_stream_arn = module.kinesis.enriched_pageviews_stream_arn
  user_table_arn = module.dynamodb.user_table_arn
}

module "s3" {
  source = "../modules/s3"
}

module "kinesis" {
  source = "../modules/kinesis"
  enriched_pageviews_s3_bucket_arn = module.s3.enriched_pageviews_s3_bucket_arn
  pageviews_count_by_postcode_s3_bucket_arn = module.s3.pageviews_count_by_postcode_s3_bucket_arn
  enriched_pageview_firehose_role_arn = module.iam.enriched_pageview_firehose_role_arn
  pageviews_count_by_postcode_firehose_role_arn = module.iam.pageviews_count_by_postcode_firehose_role_arn
}

module "dynamodb" {
  source = "../modules/dynamodb"
}

module "lambda" {
  source = "../modules/lambda"
  user_stream_arn = module.kinesis.user_stream_arn
  pageviews_stream_arn = module.kinesis.pageviews_stream_arn
  enriched_pageviews_stream_arn = module.kinesis.enriched_pageviews_stream_arn
  user_table_arn = module.dynamodb.user_table_arn
  lambda_user_consumer_role_arn = module.iam.lambda_user_consumer_role_arn
  lambda_pageviews_consumer_role_arn = module.iam.lambda_pageviews_consumer_role_arn
}
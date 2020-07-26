output "lambda_pageviews_consumer_role_arn" {
  value = aws_iam_role.lambda_pageviews_consumer_role.arn
}

output "lambda_user_consumer_role_arn" {
  value = aws_iam_role.lambda_user_consumer_role.arn
}

output "enriched_pageview_firehose_role_arn" {
  value = aws_iam_role.enriched_pageview_firehose_role.arn
}

output "pageviews_count_by_postcode_firehose_role_arn" {
  value = aws_iam_role.pageviews_count_by_postcode_firehose_role.arn
}
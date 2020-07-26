output "enriched_pageviews_stream_arn" {
  value = aws_kinesis_stream.enriched_pageviews_stream.arn
}

output "pageviews_stream_arn" {
  value = aws_kinesis_stream.pageviews_stream.arn
}

output "user_stream_arn" {
  value = aws_kinesis_stream.user_stream.arn
}
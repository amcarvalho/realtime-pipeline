output "enriched_pageview_stream_arn" {
  value = aws_kinesis_stream.enriched_pageview_stream.arn
}

output "pageview_stream_arn" {
  value = aws_kinesis_stream.pageview_stream.arn
}

output "user_stream_arn" {
  value = aws_kinesis_stream.user_stream.arn
}
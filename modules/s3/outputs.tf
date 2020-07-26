output "enriched_pageviews_s3_bucket_arn" {
  value = aws_s3_bucket.enriched-pageviews-bucket.arn
}

output "pageviews_count_by_postcode_s3_bucket_arn" {
  value = aws_s3_bucket.pageviews-count-by-postcode-bucket.arn
}
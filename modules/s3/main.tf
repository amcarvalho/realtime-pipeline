resource "aws_s3_bucket" "bucket" {
  bucket = "enriched-pageviews"
  acl    = "private"
}
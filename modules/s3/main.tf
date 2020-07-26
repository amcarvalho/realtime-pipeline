resource "aws_s3_bucket" "enriched-pageviews-bucket" {
  bucket = "enriched-pageviews"
  acl    = "private"
}

resource "aws_s3_bucket" "pageviews-count-by-postcode-bucket" {
  bucket = "pageviews-count-by-postcode"
  acl = "private"
}
/*---------------------------------------------------------------------------------------
© 2023 Amazon Web Services, Inc. or its affiliates. All Rights Reserved.
 
This AWS Content is provided subject to the terms of the AWS Customer Agreement
available at http://aws.amazon.com/agreement or other written agreement between
Customer and either Amazon Web Services, Inc. or Amazon Web Services EMEA SARL or both.
---------------------------------------------------------------------------------------*/


resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encrypt_s3" {
  bucket = aws_s3_bucket.this.bucket

  rule {
    bucket_key_enabled = false

    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# resource "aws_s3_bucket_acl" "this" {
#   bucket = aws_s3_bucket.this.id
#   acl    = "private"
# }

resource "aws_s3_bucket_versioning" "this" {
  count = var.enable_versioning ? 1 : 0

  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = ! strcontains(aws_s3_bucket.this.bucket, "log") ? "Enabled" : "Suspended"
    # status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id
  policy = var.bucket_policy
}

resource "aws_s3_bucket_logging" "this" {
  count = var.enable_log_bucket ? 1 : 0

  bucket        = aws_s3_bucket.this.id
  target_bucket = aws_s3_bucket.log_bucket[0].id
  target_prefix = "logs/"
}

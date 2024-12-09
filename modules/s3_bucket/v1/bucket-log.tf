/*---------------------------------------------------------------------------------------
© 2023 Amazon Web Services, Inc. or its affiliates. All Rights Reserved.
 
This AWS Content is provided subject to the terms of the AWS Customer Agreement
available at http://aws.amazon.com/agreement or other written agreement between
Customer and either Amazon Web Services, Inc. or Amazon Web Services EMEA SARL or both.
---------------------------------------------------------------------------------------*/


resource "aws_s3_bucket" "log_bucket" {
  count = var.enable_log_bucket ? 1 : 0

  bucket = "${var.bucket_name}-log"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "log_bucket_encrypt" {
  count = var.enable_log_bucket ? 1 : 0

  bucket = aws_s3_bucket.log_bucket[0].bucket

  rule {
    bucket_key_enabled = false

    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "log_bucket_block_public_access" {
  count = var.enable_log_bucket ? 1 : 0

  bucket = aws_s3_bucket.log_bucket[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "log_bucket_policy" {
  count = var.enable_log_bucket ? 1 : 0

  bucket = aws_s3_bucket.log_bucket[0].id
  policy = <<EOT
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "S3ServerAccessLogsPolicy",
            "Effect": "Allow",
            "Principal": {
                "Service": "logging.s3.amazonaws.com"
            },
            "Action": [
                "s3:PutObject"
            ],
            "Resource": "arn:aws:s3:::${var.bucket_name}-log/*"
        },
        {
          "Sid": "AllowSSLRequestsOnly",
          "Effect": "Deny",
          "Principal": "*",
          "Action": "s3:*",
          "Resource": [
            "arn:aws:s3:::${var.bucket_name}-log",
            "arn:aws:s3:::${var.bucket_name}-log/*"
          ],
          "Condition": {
            "Bool": {
              "aws:SecureTransport": "false"
            }
          }
        }
    ]
}						
  EOT
}
data "aws_iam_role" "role" {
  name = var.iam_role_name
}

resource "aws_s3_bucket_replication_configuration" "rule" {
  role   = data.aws_iam_role.role.arn
  bucket = var.source_bucket_id

  dynamic "rule" {
    for_each = var.rules
    content {
      id = rule.value.rule_id

      filter {
        prefix = rule.value.rule_prefix
      }
      status   = var.status
      priority = rule.value.priority
      delete_marker_replication {
        status = "Enabled"
      }
      destination {
        bucket        = "arn:aws:s3:::${var.destination_bucket_name}"
        storage_class = "STANDARD"
        account       = var.target_account
        access_control_translation {
          owner = "Destination"
        }
      }
    }
  }
}
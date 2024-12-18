###################################################
# Lifecycle Rules for S3 Bucket
###################################################

# INFO: Not supported attributes
# - `expected_bucket_owner`
resource "aws_s3_bucket_lifecycle_configuration" "this" {
  count = length(var.lifecycle_rules) > 0 ? 1 : 0

  bucket = var.bucket_name

  dynamic "rule" {
    for_each = var.lifecycle_rules

    content {
      id     = rule.value.id
      status = rule.value.enabled ? "Enabled" : "Disabled"

      dynamic "abort_incomplete_multipart_upload" {
        for_each = rule.value.abort_incomplete_multipart_upload != null ? [rule.value.abort_incomplete_multipart_upload] : []

        content {
          days_after_initiation = abort_incomplete_multipart_upload.value.days
        }
      }

      ## Single Filter
      dynamic "filter" {
        for_each = sum([
          rule.value.prefix != null ? 1 : 0,
          rule.value.min_object_size != null ? 1 : 0,
          rule.value.max_object_size != null ? 1 : 0,
        ]) == 1 ? ["go"] : []

        content {
          prefix = rule.value.prefix

          object_size_greater_than = rule.value.min_object_size
          object_size_less_than    = rule.value.max_object_size
        }
      }

      # ## Multi Filter
      # dynamic "filter" {
      #   for_each = sum([
      #     rule.value.prefix != null ? 1 : 0,
      #     rule.value.tags != null ? 2 : 0,
      #     rule.value.min_object_size != null ? 1 : 0,
      #     rule.value.max_object_size != null ? 1 : 0,
      #   ]) > 1 ? ["go"] : []

      #   content {
      #     and {
      #       prefix = rule.value.prefix
      #       tags   = rule.value.tags

      #       object_size_greater_than = rule.value.min_object_size
      #       object_size_less_than    = rule.value.max_object_size
      #     }
      #   }
      # }

      dynamic "transition" {
        for_each = rule.value.transitions

        content {
          date = transition.value.date
          days = transition.value.days

          storage_class = transition.value.storage_class
        }
      }

      dynamic "noncurrent_version_transition" {
        for_each = rule.value.noncurrent_version_transitions

        content {
          noncurrent_days           = noncurrent_version_transition.value.days
          newer_noncurrent_versions = noncurrent_version_transition.value.count

          storage_class = noncurrent_version_transition.value.storage_class
        }
      }

      dynamic "expiration" {
        for_each = rule.value.expiration != null ? [rule.value.expiration] : []

        content {
          date = expiration.value.date
          days = expiration.value.days

          expired_object_delete_marker = expiration.value.expired_object_delete_marker
        }
      }

      dynamic "noncurrent_version_expiration" {
        for_each = rule.value.noncurrent_version_expiration != null ? [rule.value.noncurrent_version_expiration] : []

        content {
          noncurrent_days           = noncurrent_version_expiration.value.days
          newer_noncurrent_versions = noncurrent_version_expiration.value.count
        }
      }
    }
  }
}
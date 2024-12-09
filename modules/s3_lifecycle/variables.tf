variable "bucket_name" {
  description = "S3 bucket Name"
}


variable "lifecycle_rules" {
  description = <<EOF
  (Optional) A configurations of Lifecycle Rules for the S3 bucket. Use lifecycle rules to define actions you want Amazon S3 to take during an object's lifetime such as transitioning objects to another storage class, archiving them, or deleting them after a specified period of time. Each value of `lifecycle_rules` as defined below.
    (Required) `id` - Unique identifier for the rule. The value cannot be longer than 255 characters.
    (Optional) `enabled` - Whether the rule is activated.
    (Optional) `prefix` - The prefix identifying one or more objects to which the rule applies. Defaults to an empty string (`""`) if not specified.
    (Optional) `tags` - A map of tag keys and values to filter.
    (Optional) `min_object_size` - Minimum object size (in bytes) to which the rule applies.
    (Optional) `max_object_size` - Maximum object size (in bytes) to which the rule applies.
    (Optional) `transitions` - A set of configurations to specify when object transitions to a specified storage class.
    (Optional) `noncurrent_version_transitions` - A set of configurations to specify when transitions of noncurrent object versions to a specified storage class.
    (Optional) `expiration` - Configurations to specify the expiration for the lifecycle of the object.
    (Optional) `noncurrent_version_expiration` - Configurations to specify when noncurrent object versions expire.
    (Optional) `abort_incomplete_multipart_upload` - Configurations to specify when S3 will permanently remove all incomplete multipart upload.
  EOF
  type = list(object({
    id      = string
    enabled = optional(bool, true)

    prefix          = optional(string)
    tags            = optional(map(string))
    min_object_size = optional(number)
    max_object_size = optional(number)

    transitions = optional(set(object({
      date = optional(string)
      days = optional(number)

      storage_class = string
    })), [])
    noncurrent_version_transitions = optional(set(object({
      count = optional(number)
      days  = number

      storage_class = string
    })), [])
    expiration = optional(object({
      date = optional(string)
      days = optional(number)

      expired_object_delete_marker = optional(bool, false)
    }))
    noncurrent_version_expiration = optional(object({
      count = optional(number)
      days  = number
    }))
    abort_incomplete_multipart_upload = optional(object({
      days = number
    }))
  }))
  default  = []
  nullable = false
}
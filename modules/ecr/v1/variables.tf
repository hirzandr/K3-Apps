/*---------------------------------------------------------------------------------------
© 2022 Amazon Web Services, Inc. or its affiliates. All Rights Reserved.
 
This AWS Content is provided subject to the terms of the AWS Customer Agreement
available at http://aws.amazon.com/agreement or other written agreement between
Customer and either Amazon Web Services, Inc. or Amazon Web Services EMEA SARL or both.
---------------------------------------------------------------------------------------*/

variable "name" {
  description = "ECR Name, Should be a Service Name or COntainer Name"
}

## Glue Connection Parameters ##
variable "image_tag_mutability" {
  type        = string
  description = "The tag mutability setting for the repository. Must be one of: MUTABLE or IMMUTABLE"
  default     = "IMMUTABLE"
}

variable "scan_on_push" {
  description = "(Required) Indicates whether images are scanned after being pushed to the repository (true) or not scanned (false)."
  type        = bool
  default     = true
}

variable "encryption_type" {
  description = "The encryption type to use for the repository. Valid values are AES256 or KMS"
  type        = string
  default     = "AES256"
}

variable "kms_key_arn" {
  description = "The ARN of the KMS key to use when encryption_type is KMS."
  type        = string
  default     = null
}

variable "create_lifecycle_policy" {
  description = "Whether to create LifeCYcle Policy for the images."
  type        = bool
  default     = false
}

# variable "policy_json"{
#     description="The policy document. This is a JSON formatted string.."
#     type = any
#     default = null
# }


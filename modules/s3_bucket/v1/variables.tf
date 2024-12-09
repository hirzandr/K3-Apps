/*---------------------------------------------------------------------------------------
© 2023 Amazon Web Services, Inc. or its affiliates. All Rights Reserved.
 
This AWS Content is provided subject to the terms of the AWS Customer Agreement
available at http://aws.amazon.com/agreement or other written agreement between
Customer and either Amazon Web Services, Inc. or Amazon Web Services EMEA SARL or both.
---------------------------------------------------------------------------------------*/


variable "bucket_name" {
  type        = string
  description = "Name of S3 Bucket"
}

variable "bucket_policy" {
  type        = string
  description = "S3 Bucket access policy"
}

variable "enable_log_bucket" {
  type        = bool
  description = "Configure log bucket"
}

variable "enable_versioning" {
  type        = bool
  description = "Configure bucket versioning"
}
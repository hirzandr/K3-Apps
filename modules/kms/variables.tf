/*---------------------------------------------------------------------------------------
© 2022 Amazon Web Services, Inc. or its affiliates. All Rights Reserved.
 
This AWS Content is provided subject to the terms of the AWS Customer Agreement
available at http://aws.amazon.com/agreement or other written agreement between
Customer and either Amazon Web Services, Inc. or Amazon Web Services EMEA SARL or both.
---------------------------------------------------------------------------------------*/

variable "alias_name" {
  description = "Name of the Glue COnnection"
}

## Glue Connection Parameters ##
variable "description" {
  type        = string
  description = "Alias Description"
}

variable "tags" {
  description = "tagging"
  default     = {}
}

variable "iam_policy_document_json" {
  description = "IAM Policy for KMS"
}
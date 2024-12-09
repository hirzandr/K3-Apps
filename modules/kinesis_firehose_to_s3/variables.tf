variable "firehose_iam_role" {
  description = "name of the iam role you want to attach to the Firehose"
}

variable "delivery_stream_name" {
  description = "Firehose Delivery Stream Name"
}

variable "kinesis_stream_name" {
  description = "Source Kinesis Stream Name"
}

# variable "key_arn" {
#   description = "Customer Managed KMS ARn"
#   default = null
# }


##### S3 Target Configuration #####

variable "target_bucket_name" {
  description = "name of the destination bucket"
}

variable "buffering_size" {
  description = "Buffering Size with default 5MB"
  type        = number
  default     = 5
}

variable "buffering_interval" {
  description = "Buffering Size with default 5MB"
  type        = number
  default     = 300
}

variable "dynamic_partitioning" {
  description = "Dynamic Partitioning"
  default     = true
}


# variable "s3_kms_key_arn" {
#   description = "Customer Managed KMS ARn of S3 bucket"
#   default = null
# }



variable "prefix" {
  description = "prefix of object that is stored in S3"
}

variable "error_prefix" {
  description = "account id of the destination bucket"
  default     = "errors/"
}



# Related to Data Transformation
variable "process_enabled" {
  description = "Currently no transformation"
  default     = false
}

# Related to Data Format Transformation
variable "data_format_conversion_configuration" {
  description = "Data format configuration. Value is true or false"
  default     = false
}





# Related to Glue Table Creation
# variable "storage_descriptor_location"{

# }

# variable "storage_descriptor_input_format"{

# }

# variable "storage_descriptor_output_format"{

# }


variable "s3_bucket_glue_table" {
  description = "S3 Location for Glue Table"
}

variable "storage_columns" {
  description = "Storage Descriptor for Glue Table"
  # type = map(object({
  #   columns = set(object({
  #     name = string
  #     type  = string
  #   }))
  # }))

  default = {
    columns_1 = {
      name = "common header"
      type = "struct"
    }

    columns_2 = {
      name = "contained data list"
      type = "array"
    }

    columns_3 = {
      name    = "continuous id"
      type    = "string"
      comment = ""
    }

    columns_4 = {
      name    = "initialize id"
      type    = "string"
      comment = ""
    }
  }
}


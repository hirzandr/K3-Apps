data "aws_iam_role" "firehose_role" {
  name = var.firehose_iam_role
}

data "aws_kinesis_stream" "stream" {
  name = var.kinesis_stream_name
}

data "aws_s3_bucket" "s3_bucket_glue_table" {
  bucket = var.s3_bucket_glue_table
}


resource "aws_glue_catalog_database" "aws_glue_catalog_database" {
  name = "${var.delivery_stream_name}-catalog_db"

  # create_table_default_permission {
  #   permissions = ["SELECT"]

  #   principal {
  #     data_lake_principal_identifier = "IAM_ALLOWED_PRINCIPALS"
  #   }
  # }
}

resource "aws_glue_catalog_table" "aws_glue_catalog_table" {
  name          = "${var.delivery_stream_name}-catalog_tbl"
  database_name = "${var.delivery_stream_name}-catalog_db"


  # storage_descriptor { ${var.storage_descriptor} }

  storage_descriptor {
    # location      = "s3://my-bucket/event-streams/my-stream"
    location = "s3://${data.aws_s3_bucket.s3_bucket_glue_table.id}/glue_table"
    # input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    # output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

    # ser_de_info {
    #   name                  = "my-stream"
    #   serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"

    #   parameters = {
    #     "serialization.format" = 1
    #   }
    # }

    dynamic "columns" {
      for_each = var.storage_columns
      content {
        name = columns.value["name"]
        type = columns.value["type"]
      }
    }

  }

  depends_on = [aws_glue_catalog_database.aws_glue_catalog_database]
}



## Create Kinesis Firehose Delivery Stream ##
resource "aws_kinesis_firehose_delivery_stream" "extended_s3_stream_no_processing" {
  count      = var.process_enabled == false ? 1 : 0
  depends_on = [aws_glue_catalog_table.aws_glue_catalog_table]


  name        = var.delivery_stream_name
  destination = "extended_s3"


  kinesis_source_configuration {
    kinesis_stream_arn = data.aws_kinesis_stream.stream.arn
    role_arn           = data.aws_iam_role.firehose_role.arn
  }

  #### 20230823 - Encryption is disabled ####

  # server_side_encryption {
  #   enabled = var.key_arn == null ? false : true

  #   key_type = "CUSTOMER_MANAGED_CMK"

  #   key_arn = var.key_arn
  # }

  ############################################

  extended_s3_configuration {
    role_arn = data.aws_iam_role.firehose_role.arn

    bucket_arn = "arn:aws:s3:::${var.target_bucket_name}"


    # kms_key_arn = var.s3_kms_key_arn

    buffer_size     = var.buffering_size     # between 1 - 100 MB, default 5 MB.
    buffer_interval = var.buffering_interval # between 60 to 900 seconds, default 300 seconds.

    dynamic_partitioning_configuration {
      enabled = var.dynamic_partitioning
    }

    prefix              = var.prefix       #"data/customer_id=!{partitionKeyFromQuery:customer_id}/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/hour=!{timestamp:HH}/"
    error_output_prefix = var.error_prefix #"errors/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/hour=!{timestamp:HH}/!{firehose:error-output-type}/"


    processing_configuration {
      enabled = var.process_enabled
    }

    # ... other configuration ...
    data_format_conversion_configuration {

      enabled = var.data_format_conversion_configuration

      input_format_configuration {
        deserializer {
          hive_json_ser_de {}
        }
      }

      output_format_configuration {
        serializer {
          parquet_ser_de {}
        }
      }

      schema_configuration {
        database_name = aws_glue_catalog_table.aws_glue_catalog_table.database_name
        role_arn      = data.aws_iam_role.firehose_role.arn
        table_name    = aws_glue_catalog_table.aws_glue_catalog_table.name
      }
    }
  }
}



# resource "aws_kinesis_firehose_delivery_stream" "extended_s3_stream_with_processing" {
#   count = var.process_enabled == true ? 1 : 0
#   name        = var.delivery_stream_name
#   destination = "extended_s3"

#   extended_s3_configuration {
#     role_arn   = data.aws_iam_role.firehose_role.arn
#     bucket_arn = var.bucket_arn

#     processing_configuration {
#       enabled = var.process_enabled

#       processors {
#         type = "Lambda"

#         parameters {
#           parameter_name  = "LambdaArn"
#           parameter_value = "${aws_lambda_function.lambda_processor.arn}:$LATEST"
#         }
#       }
#     }
#   }
# }
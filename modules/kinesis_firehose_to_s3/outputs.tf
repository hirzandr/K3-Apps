output "arn" {
  value = aws_kinesis_firehose_delivery_stream.extended_s3_stream_no_processing[0].arn
}
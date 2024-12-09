resource "aws_sns_topic" "user_updates" {
  name = var.sns_topic_name
  display_name = var.sns_topic_name

  kms_master_key_id = try(var.kms_key_id,null)

}
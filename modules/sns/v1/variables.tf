variable "sns_topic_name"{
    description = "name of the sns topic"
    type = string
}


variable "kms_key_id" {
    description = "CMK key ID"
    type = string
    default = "alias/aws/sns"
}


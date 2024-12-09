variable "iam_role_name" {
  description = "name of the iam role you want to attach to the replication rule"
}

variable "source_bucket_id" {
  description = "id of the bucket"
}

variable "rules" {
  description = "id for the replication rule"
}

variable "status" {
  description = "status for the replication rule"
}
/*
variable "existing_object_replication"{
    description = "to enable existing object replication"
}
*/
variable "destination_bucket_name" {
  description = "name of the destination bucket"
}

variable "target_account" {
  description = "account id of the destination bucket"
}
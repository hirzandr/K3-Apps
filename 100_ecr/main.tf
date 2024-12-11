



module "ecr" {
  source = "./../modules/ecr/v1"

  for_each = var.ecr_repository_items

  name                 = each.value.name
  image_tag_mutability = each.value.image_tag_mutability

  scan_on_push = each.value.scan_on_push


  encryption_type = each.value.encryption_type

  kms_key_arn = try(each.value.kms_key_arn, null)


  create_lifecycle_policy = try(each.value.create_lifecycle_policy, false)

  #policy_json             = try(each.value.policy_json, null)
  
}


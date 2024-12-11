#################### ECR ####################
#############################################
ecr_repository_items = {
  ecr_1 = {
    name                    = "prod-k3-frontend"
    image_tag_mutability    = "IMMUTABLE"
    scan_on_push            = true
    encryption_type         = "AES256"
    kms_key_arn             = null
    create_lifecycle_policy = true
  },

ecr_2 = {
    name                    = "prod-k3-api"
    image_tag_mutability    = "IMMUTABLE"
    scan_on_push            = true
    encryption_type         = "AES256"
    kms_key_arn             = null
    create_lifecycle_policy = true
  },

ecr_3 = {
    name                    = "prod-k3-worker"
    image_tag_mutability    = "IMMUTABLE"
    scan_on_push            = true
    encryption_type         = "AES256"
    kms_key_arn             = null
    create_lifecycle_policy = true
  },

ecr_4 = {
    name                    = "prod-k3-scheduler"
    image_tag_mutability    = "IMMUTABLE"
    scan_on_push            = true
    encryption_type         = "AES256"
    kms_key_arn             = null
    create_lifecycle_policy = true
  },

# ecr_5 = {
#     name                    = "prod-k3-websocket"
#     image_tag_mutability    = "IMMUTABLE"
#     scan_on_push            = true
#     encryption_type         = "AES256"
#     kms_key_arn             = null
#     create_lifecycle_policy = true
#   },
# ecr_6 = {
#     name                    = "uat-docapps-be-caregiver"
#     image_tag_mutability    = "IMMUTABLE"
#     scan_on_push            = true
#     encryption_type         = "AES256"
#     kms_key_arn             = null
#     create_lifecycle_policy = true
#   },
# ecr_7 = {
#     name                    = "prod-k3-be-notification"
#     image_tag_mutability    = "IMMUTABLE"
#     scan_on_push            = true
#     encryption_type         = "AES256"
#     kms_key_arn             = null
#     create_lifecycle_policy = true
#   },
}
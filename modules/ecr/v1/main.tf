



resource "aws_ecr_repository" "this" {
  name                 = var.name                 # "bar"
  image_tag_mutability = var.image_tag_mutability # "IMMUTABLE"/"MUTABLE"

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  encryption_configuration {
    encryption_type = var.encryption_type #"AES256"
    kms_key         = var.encryption_type == "AES256" ? null : var.kms_key_arn
  }

}


# resource "aws_ecr_lifecycle_policy" "this" {
#     count = var.create_lifecycle_policy == true ? 1:0
#     repository = aws_ecr_repository.this.name

#     policy = var.policy_json
#     # policy = <<EOF
#     # {
#     #     "rules": [
#     #         {
#     #             "rulePriority": 1,
#     #             "description": "Expire images older than 14 days",
#     #             "selection": {
#     #                 "tagStatus": "untagged",
#     #                 "countType": "sinceImagePushed",
#     #                 "countUnit": "days",
#     #                 "countNumber": 14
#     #             },
#     #             "action": {
#     #                 "type": "expire"
#     #             }
#     #         }
#     #     ]
#     # }
#     # EOF
# }
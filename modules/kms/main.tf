resource "aws_kms_key" "this" {
  description         = var.description
  enable_key_rotation = true

  policy = var.iam_policy_document_json
  tags   = var.tags
}


resource "aws_kms_alias" "this" {
  depends_on = [aws_kms_key.this]

  name          = "alias/${var.alias_name}"
  target_key_id = aws_kms_key.this.key_id
}


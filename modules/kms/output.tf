
output "out_alias_arn" {
  value = aws_kms_alias.this.arn
}

output "out_alias_target_arn" {
  value = aws_kms_alias.this.target_key_arn
}

output "out_key_id" {
  value = aws_kms_key.this.key_id
}
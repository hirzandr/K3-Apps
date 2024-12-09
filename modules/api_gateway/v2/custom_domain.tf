/*---------------------------------------------------------------------------------------
© 2022 Amazon Web Services, Inc. or its affiliates. All Rights Reserved.
 
This AWS Content is provided subject to the terms of the AWS Customer Agreement
available at http://aws.amazon.com/agreement or other written agreement between
Customer and either Amazon Web Services, Inc. or Amazon Web Services EMEA SARL or both.
---------------------------------------------------------------------------------------*/

locals {
  create_domain = var.api_domain_name != null ? 1 : 0
}

resource "aws_api_gateway_domain_name" "this" {
  count = local.create_domain

  domain_name              = var.api_domain_name
  regional_certificate_arn = var.domain_cert_arn

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_base_path_mapping" "this" {
  count = local.create_domain

  api_id      = aws_api_gateway_rest_api.this.id
  stage_name  = aws_api_gateway_stage.this.stage_name
  domain_name = aws_api_gateway_domain_name.this[0].domain_name
}

# resource "aws_route53_zone" "this" {
#   count = local.create_domain

#   name = var.api_domain_name

#   vpc {
#     vpc_id = var.vpc_id
#   }
# }

# resource "aws_route53_record" "this" {
#   count = local.create_domain

#   name    = aws_api_gateway_domain_name.this[0].domain_name
#   type    = "A"
#   zone_id = aws_route53_zone.this[0].id

#   alias {
#     evaluate_target_health = true
#     name                   = aws_api_gateway_domain_name.this[0].regional_domain_name
#     zone_id                = aws_api_gateway_domain_name.this[0].regional_zone_id
#   }
# }
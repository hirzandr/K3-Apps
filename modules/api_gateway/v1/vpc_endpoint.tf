/*---------------------------------------------------------------------------------------
© 2022 Amazon Web Services, Inc. or its affiliates. All Rights Reserved.
 
This AWS Content is provided subject to the terms of the AWS Customer Agreement
available at http://aws.amazon.com/agreement or other written agreement between
Customer and either Amazon Web Services, Inc. or Amazon Web Services EMEA SARL or both.
---------------------------------------------------------------------------------------*/

################################################################################
# VPC Endpoint for API GW
################################################################################

# resource "aws_vpc_endpoint" "this" {
#   count = var.vpc_endpoint_id != null ? 1 : 0

#   private_dns_enabled = true
#   security_group_ids  = var.security_group_ids
#   service_name        = "com.amazonaws.${var.region}.execute-api"
#   subnet_ids          = var.subnet_ids
#   vpc_endpoint_type   = "Interface"
#   vpc_id              = var.vpc_id

#   tags = merge(var.tags, {
#     "Name" = var.api_gateway_name
#   })
# }
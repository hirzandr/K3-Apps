/*---------------------------------------------------------------------------------------
© 2022 Amazon Web Services, Inc. or its affiliates. All Rights Reserved.
 
This AWS Content is provided subject to the terms of the AWS Customer Agreement
available at http://aws.amazon.com/agreement or other written agreement between
Customer and either Amazon Web Services, Inc. or Amazon Web Services EMEA SARL or both.
---------------------------------------------------------------------------------------*/

output "api_gateway_id" {
  value = try(aws_api_gateway_rest_api.this.id, "")
}

output "api_gateway_arn" {
  value = try(aws_api_gateway_rest_api.this.arn, "")
}

output "api_gateway_name" {
  value = try(aws_api_gateway_rest_api.this.name, "")
}

# output "vpc_endpoint_network_interface_ids" {
#   value = try(aws_vpc_endpoint.this[0].network_interface_ids, "")
# }

# output "api_gateway_vpc_link_id" {
#   value = try(aws_api_gateway_vpc_link.this[0].id, "")
# }




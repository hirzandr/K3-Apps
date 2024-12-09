/*---------------------------------------------------------------------------------------
© 2022 Amazon Web Services, Inc. or its affiliates. All Rights Reserved.
 
This AWS Content is provided subject to the terms of the AWS Customer Agreement
available at http://aws.amazon.com/agreement or other written agreement between
Customer and either Amazon Web Services, Inc. or Amazon Web Services EMEA SARL or both.
---------------------------------------------------------------------------------------*/

variable "api_gateway_name" {
  description = "Name of API gateway"
}

variable "api_gw_stage_name" {
  description = "API Gateway stage name"
}

variable "api_spec_body" {
  type        = string
  description = "API Spec body in OpenAPI 3.0 format"
}

variable "api_gw_stage_variables" {
  type        = map(any)
  default     = {}
  description = "API Gateway stage variables"
}

# variable "nlb_vpc_link_arn" {
#   type = string
#   nullable = true
#   default = null
#   description = "NLB arn for api gateway VPC Link integration"
# }

variable "api_domain_name" {
  type        = string
  nullable    = true
  default     = null
  description = "Domain for API Gateway"

}

variable "domain_cert_arn" {
  type        = string
  nullable    = true
  default     = null
  description = "Domain Cert for API Gateway"
}

variable "vpc_endpoint_id" {
  type        = string
  nullable    = true
  default     = null
  description = "VPC endpoint id used for API GW"
}

variable "vpc_id" {
  type        = string
  description = "VPC id used for API GW VPC Endpoint"
}

variable "subnet_ids" {
  type        = list(any)
  nullable    = true
  default     = null
  description = "List of subnet id used for API GW VPC Endpoint"
}

variable "security_group_ids" {
  type        = list(any)
  nullable    = true
  default     = null
  description = "List of security id used for API GW VPC Endpoint"
}

variable "region" {
  type        = string
  description = "Region of the AWS Resources"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
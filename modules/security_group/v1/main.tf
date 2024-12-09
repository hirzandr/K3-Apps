/*---------------------------------------------------------------------------------------
© 2022 Amazon Web Services, Inc. or its affiliates. All Rights Reserved.
 
This AWS Content is provided subject to the terms of the AWS Customer Agreement
available at http://aws.amazon.com/agreement or other written agreement between
Customer and either Amazon Web Services, Inc. or Amazon Web Services EMEA SARL or both.
---------------------------------------------------------------------------------------*/


terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"

      version = ">= 3.5, != 3.14.0"
    }
    template = {
      source = "hashicorp/template"
    }
    time = {
      source = "hashicorp/time"
    }
  }
}


resource "aws_security_group" "main" {
  name        = var.name
  description = var.description
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      description     = ingress.value.description
      from_port       = ingress.value.from_port
      to_port         = ingress.value.to_port
      protocol        = ingress.value.protocol
      security_groups = ingress.value.security_groups
      cidr_blocks     = ingress.value.cidr_blocks
      prefix_list_ids = try(ingress.value.prefix_list_ids, [])
    }

  }

  dynamic "egress" {
    for_each = var.egress_rules
    content {
      description     = egress.value.description
      from_port       = egress.value.from_port
      to_port         = egress.value.to_port
      protocol        = egress.value.protocol
      cidr_blocks     = egress.value.cidr_blocks
      security_groups = egress.value.security_groups
      prefix_list_ids = try(egress.value.prefix_list_ids, [])
    }
  }

  tags = var.tags
}

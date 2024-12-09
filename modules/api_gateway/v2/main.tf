/*---------------------------------------------------------------------------------------
© 2022 Amazon Web Services, Inc. or its affiliates. All Rights Reserved.
 
This AWS Content is provided subject to the terms of the AWS Customer Agreement
available at http://aws.amazon.com/agreement or other written agreement between
Customer and either Amazon Web Services, Inc. or Amazon Web Services EMEA SARL or both.
---------------------------------------------------------------------------------------*/

# Reference : https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_rest_api

################################################################################
# API GW REST
################################################################################

resource "aws_api_gateway_rest_api" "this" {
  body = var.api_spec_body

  name = var.api_gateway_name

  put_rest_api_mode = "merge"

  endpoint_configuration {
    types            = ["PRIVATE"]
    vpc_endpoint_ids = [var.vpc_endpoint_id]
  }

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }

}

################################################################################
# API GW Deployment
################################################################################
resource "aws_api_gateway_deployment" "this" {
  depends_on = [aws_api_gateway_rest_api_policy.this]

  rest_api_id = aws_api_gateway_rest_api.this.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.this.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

################################################################################
# API GW Stage Cloudwatch Log Group
################################################################################
resource "aws_cloudwatch_log_group" "access_log" {
  count = var.create_access_logs != null && var.default_stage_access_log_format != null ? 1 : 0

  name = "${var.api_gateway_name}-access-log"

  retention_in_days = var.access_logs_retention_days

  kms_key_id = var.access_logs_kms_key
}

################################################################################
# API GW Stage
################################################################################
resource "aws_api_gateway_stage" "this" {
  deployment_id = aws_api_gateway_deployment.this.id
  rest_api_id   = aws_api_gateway_rest_api.this.id
  stage_name    = var.api_gw_stage_name

  variables = var.api_gw_stage_variables

  # cache_cluster_enabled = true


  dynamic "access_log_settings" {
    for_each = var.create_access_logs != false && var.default_stage_access_log_format != null ? [true] : []

    content {
      destination_arn = aws_cloudwatch_log_group.access_log[0].arn
      format          = var.default_stage_access_log_format
    }
  }

  tags = var.tags
}


################################################################################
# API GW Resource Policy
################################################################################
data "aws_iam_policy_document" "this" {
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions   = ["execute-api:Invoke"]
    resources = ["${aws_api_gateway_rest_api.this.execution_arn}*"]
  }

  statement {
    effect = "Deny"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions   = ["execute-api:Invoke"]
    resources = ["${aws_api_gateway_rest_api.this.execution_arn}*"]

    condition {
      test     = "StringNotEquals"
      variable = "aws:SourceVpc"
      values   = [var.vpc_id]
    }
  }
}

resource "aws_api_gateway_rest_api_policy" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  policy      = var.rest_api_policy != "" ? var.rest_api_policy : data.aws_iam_policy_document.this.json
}

################################################################################
# API GW Logging Level
################################################################################
resource "aws_api_gateway_method_settings" "all" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  stage_name  = aws_api_gateway_stage.this.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled = true
    logging_level   = "ERROR"
  }
}
/*---------------------------------------------------------------------------------------
© 2022 Amazon Web Services, Inc. or its affiliates. All Rights Reserved.
 
This AWS Content is provided subject to the terms of the AWS Customer Agreement
available at http://aws.amazon.com/agreement or other written agreement between
Customer and either Amazon Web Services, Inc. or Amazon Web Services EMEA SARL or both.
---------------------------------------------------------------------------------------*/

resource "aws_cloudwatch_metric_alarm" "this" {
  alarm_name                = var.alarm_name
  alarm_description         = var.alarm_description #"This metric monitors jvm Heap Usage of Glue Job: ${var.job_name}"

  comparison_operator       = var.comparison_operator #"GreaterThanOrEqualToThreshold"
  evaluation_periods        = var.evaluation_periods #2
  threshold                 = var.threshold #80
  period                    = var.period_seconds #300

  metric_name               = try(var.metric_name, null) #"glue.ALL.jvm.heap.usage"
  
  namespace                 = try(var.namespace, null) #"Glue"
  
  statistic                 = try(var.statistic, null) #"Average"
  
  # metric_query              = try(var.metric_query, {}) #"glue.ALL.jvm.heap.usage"

  # conflicts with metric_name
  dynamic "metric_query" {
    for_each = var.metric_query
    content {
      id          = lookup(metric_query.value, "id")
      account_id  = lookup(metric_query.value, "account_id", null)
      label       = lookup(metric_query.value, "label", null)
      return_data = lookup(metric_query.value, "return_data", null)
      expression  = lookup(metric_query.value, "expression", null)
      period      = lookup(metric_query.value, "period", null)

      dynamic "metric" {
        for_each = lookup(metric_query.value, "metric", [])
        content {
          metric_name = lookup(metric.value, "metric_name")
          namespace   = lookup(metric.value, "namespace")
          period      = lookup(metric.value, "period")
          stat        = lookup(metric.value, "stat")
          unit        = lookup(metric.value, "unit", null)
          dimensions  = lookup(metric.value, "dimensions", null)
        }
      }
    }
  }

  alarm_actions             = [var.sns_topic_arn]

  dimensions = try(var.dimensions , null)
  # {
  #   JobRunId  = "ALL"
  #   JobName   = var.job_name
  #   Type      = "gauge"
  # }
}


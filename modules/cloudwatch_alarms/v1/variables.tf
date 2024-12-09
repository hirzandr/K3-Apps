/*---------------------------------------------------------------------------------------
© 2022 Amazon Web Services, Inc. or its affiliates. All Rights Reserved.
 
This AWS Content is provided subject to the terms of the AWS Customer Agreement
available at http://aws.amazon.com/agreement or other written agreement between
Customer and either Amazon Web Services, Inc. or Amazon Web Services EMEA SARL or both.
---------------------------------------------------------------------------------------*/

variable "alarm_name" {
  type        = string
  description = "Name of the Alarm"
}

variable "alarm_description" {
  type        = string
  description = "Alarm Description"
}

variable "comparison_operator" {
  type        = string
  description = "Comparison Operator"
  default     = "GreaterThanOrEqualToThreshold"
}

variable "evaluation_periods" {
  type        = number
  description = "Evaluation Periods"
  default     = 2
}

variable "period_seconds" {
  type        = string
  description = "Periods in Seconds"
  default     = null
}

variable "threshold" {
  type        = number
  description = "Threshold of the Alarm"
}

variable "metric_name" {
  type        = string
  description = "Metric Name"
  default     = null
}

variable "namespace" {
  type        = string
  description = "NameSpace"
  default     = null
}

variable "statistic" {
  type        = string
  description = "Statistic, e.g: Average"
  default     = null
}

variable "dimensions" {
  description   = "Add Dimension for the Metric"
  type          = any
  default       = null
}

variable "metric_query" {
  description = "Enables you to create an alarm based on a metric math expression. You may specify at most 20."
  type        = any
  default     = []
}


variable "sns_topic_arn" {
  type        = string
  description = "AWS Resource Name of SNS Topic"
}



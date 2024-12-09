
output "out_alarm_arn" {
    value = aws_cloudwatch_metric_alarm.this.arn
}

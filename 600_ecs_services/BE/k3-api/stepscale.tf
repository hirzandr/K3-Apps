resource "aws_appautoscaling_policy" "ecs_policy_stepscale" {
  name               = "step-scale-up-CPU-MAX" #ubah penamaan sesuai kebutuhan
  policy_type        = "StepScaling"
  resource_id        = "service/k3-cluster-ecs-iac/prod-k3-api-iac" #Adjust sesuai nama service
  #resource_id        = "service/(cluster-name)/(service-name)"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 300 #Durasi gap untuk re-scale up/down
    metric_aggregation_type = "Maximum" #Pada umumnya untuk scale up dengan step-scale, pakai metric MAX untuk antisipasi Spike Load tinggi

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = 1 #jumlah task yang akan ditambah ketika ketrigger
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_utilization_high" {
  alarm_name          = "ecs-prod-k3-api-cpu-utilization-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "3" #berapa kali periode untuk evaluasi bahwa itu dianggap alarm
  metric_name         = "CPUUtilization" # bisa "CPUUtilization" atau "MemoryUtilization", sesuaikan dengan kebutuhan 
  namespace           = "AWS/ECS"
  period              = "60" # durasi 1x periode pengecekan utilisasi
  statistic           = "Maximum" #statistic yang diambil cloudwatch. untuk step scale pakai "Maximum"
  threshold           = "80"  # Adjust this threshold based on your needs
  alarm_description   = "This alarm triggers when CPU utilization is greater than or equal to 80% for 2 consecutive periods."
  #AutoScaleup akan terjadi ketika cloudwatch membaca utilisasi =>80% selama 2x60 detik. Sesuaikan evaluation periods & period sesuai kebutuhan service scale, semakin kecil semakin cepat 

  dimensions = {
    ClusterName = "k3-cluster-ecs-iac"  #Sesuaikan sesuai nama Cluster
    ServiceName = "prod-k3-api-iac"  #Sesuaikan sesuai nama Service
  }

  alarm_actions = [
    aws_appautoscaling_policy.ecs_policy_stepscale.arn,
  ]
}
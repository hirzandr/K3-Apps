locals {
  name              = "prod-k3-api-iac"
  cluster_name      = "k3-cluster-ecs-iac"
  target_group_arn  = "arn:aws:elasticloadbalancing:ap-southeast-3:235494785181:targetgroup/k3-be-main-web-tg-iac/a9e9755b9cf05a5f"
  container_port    = 5000
  cpu               = "256"
  memory            = "512"
  container_desired_count = 1
  security_groups = ["sg-00918e24aa54e4a10"] # alb be
}


resource "aws_ecs_task_definition" "k3" {
  container_definitions = jsonencode([
    {
      name         = local.name
      image        = "235494785181.dkr.ecr.ap-southeast-3.amazonaws.com/prod-k3-api:latest"
      cpu          = 0
      essential    = true
      logConfiguration = {
          logDriver = "awslogs"
          options   = {
              "awslogs-create-group"  = "true",
              "awslogs-group"         = "/ecs/${local.name}"
              "awslogs-region"        = "ap-southeast-3"
              "awslogs-stream-prefix" = "ecs"
          }
      },
      portMappings = [
        {
            name          = "${local.name}-port"
            containerPort = local.container_port
            hostPort      = local.container_port
            protocol      = "tcp"
            appProtocol   = "http"
        }
      ]
    }
  ])

  family                   = local.name
  requires_compatibilities = ["EC2"]

  cpu                = local.cpu
  memory             = local.memory
  network_mode       = "awsvpc"
  task_role_arn      = "arn:aws:iam::235494785181:role/ecsTaskExecutionRole"
  execution_role_arn = "arn:aws:iam::235494785181:role/ecsTaskExecutionRole"

  
}

resource "aws_ecs_service" "k3_service" {
    name                   = local.name
    cluster                = "arn:aws:ecs:ap-southeast-3:235494785181:cluster/${local.cluster_name}"
    launch_type            = "EC2"
    enable_execute_command = true

    deployment_maximum_percent         = 200
    deployment_minimum_healthy_percent = 100
    desired_count                      = local.container_desired_count
    task_definition                    = aws_ecs_task_definition.k3.arn
    health_check_grace_period_seconds  = 300

    network_configuration {
        security_groups = local.security_groups
        subnets         = var.private_subnet_ids
    }
  
    load_balancer {
        target_group_arn = local.target_group_arn
        container_name   = aws_ecs_task_definition.k3.family
        container_port   = local.container_port
    }

    ordered_placement_strategy {
      type  = "binpack"
      field = "memory"
    }

    placement_constraints {
      type       = "memberOf"
      expression = "attribute:ecs.availability-zone in [ap-southeast-3a, ap-southeast-3b]"
    }
}

resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 6
  min_capacity       = 3
  resource_id        = "service/${local.cluster_name}/${aws_ecs_service.k3_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_policy" {
  name               = "scale-up-cpu"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value        = 60
    scale_in_cooldown   = 300
    scale_out_cooldown  = 60
  }
}

resource "aws_appautoscaling_policy" "ecs_policy_mem" {
  name               = "scale-up-mem"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    target_value        = 60
    scale_in_cooldown   = 300
    scale_out_cooldown  = 60
  }
}
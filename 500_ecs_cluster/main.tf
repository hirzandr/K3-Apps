#create ecs cluster
resource "aws_ecs_cluster" "cluster_prod"{
    name = "k3-cluster-ecs-iac"

    setting {
      name  = "containerInsights"
      value = "enabled"
    }
}

# - - - EMR EC2 TEMPLATE SECURITY GROUP - - - #
resource "aws_security_group" "k3-asg-sg" {
  name_prefix = "k3-asg-sg-iac-"
  description = "Autoscaling group security group for Cluster K3"
  vpc_id      = "vpc-0c6e322ba7308224f"


  ingress {
      description     = "Allow All Traffic from Private A"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      cidr_blocks     = ["10.100.70.0/26"]
    }

    ingress {
      description     = "Allow All Traffic from Private B"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      cidr_blocks     = ["10.100.70.64/26"]
    }

    ingress {
      description     = "Allow All Traffic from Protected A"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      cidr_blocks     = ["10.100.70.160/27"]
    }

    ingress {
      description     = "Allow All Traffic from Protected B"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      cidr_blocks     = ["10.100.70.192/27"]
    }

    ingress {
      description     = "Allow All Traffic from HO"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      cidr_blocks     = ["10.1.128.0/18"]
    }
  
  egress {
      description     = "Allow Traffic"
      from_port       = 0
      to_port         = 0
      protocol        = -1
      cidr_blocks     = ["0.0.0.0/0"]
    }
}

# - - - K3 CLUSTER LAUNCH TEMPLATE - - - #
resource "aws_launch_template" "k3-cluster-temp-iac" {
  name_prefix            = "k3-cluster-temp-iac-"
  image_id               = "ami-0bc7eb7e0e53e4365"
  instance_type          = "m5.large"
  key_name = "Prod-K3-keypairs"
  vpc_security_group_ids = [aws_security_group.k3-asg-sg.id]
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      # Size of the EBS volume in GB
      volume_size = 30
      
      # Type of EBS volume (General Purpose SSD in this case)
      volume_type = "gp3"

      encrypted = true
      kms_key_id = "arn:aws:kms:ap-southeast-3:387413415276:key/7b09bd59-8a20-4de4-8008-84a351688670"
    }
  }

  instance_market_options {
    market_type = "spot"
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

    tag_specifications {
    resource_type = "instance"
    tags          = {
      "map-migrated" = "migXE6ORY1HAF"
    }
  }
  tag_specifications {
    resource_type = "volume"
    tags          = {
        "AppOwner"     = "Kairos"
        "DepartmentID" = "Kairos"
        "Environment"  = "prod"
        "Owner"        = "Kairos"
        "OwnerTeam"    = "Kairos"
        "map-migrated" = "migXE6ORY1HAF"
        "name"         = "k3-cluster-asg-iac"
    }
  }

  iam_instance_profile { arn = "arn:aws:iam::387413415276:instance-profile/ECSInstanceRole" }
  monitoring { enabled = true }

user_data = base64encode(<<-EOF
#!/bin/bash
echo ECS_CLUSTER=${aws_ecs_cluster.cluster_prod.name} >> /etc/ecs/ecs.config;
# Install CloudWatch Agent
sudo yum install amazon-cloudwatch-agent -y

# Configure CloudWatch Agent for memory metrics
cat << 'EOF_CONFIG' > /opt/aws/amazon-cloudwatch-agent/bin/config.json
{
 "agent": {
  "metrics_collection_interval": 60,
  "run_as_user": "cwagent"
 },
 "metrics": {
  "aggregation_dimensions": [
   [
    "InstanceId"
   ]
  ],
  "append_dimensions": {
   "AutoScalingGroupName": "$${aws:AutoScalingGroupName}",
   "ImageId": "$${aws:ImageId}",
   "InstanceId": "$${aws:InstanceId}",
   "InstanceType": "$${aws:InstanceType}"
  },
  "metrics_collected": {
   "collectd": {
    "metrics_aggregation_interval": 60
   },
   "disk": {
    "measurement": [
     "used_percent"
    ],
    "metrics_collection_interval": 60,
    "resources": [
     "*"
    ]
   },
   "mem": {
    "measurement": [
     "mem_used_percent"
    ],
    "metrics_collection_interval": 60
   },
   "statsd": {
    "metrics_aggregation_interval": 60,
    "metrics_collection_interval": 10,
    "service_address": ":8125"
   }
  }
 }
}
EOF_CONFIG


# Start CloudWatch Agent
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json -s


sudo bash -c "eval /opt/CrowdStrike/falconctl -s --cid=5AC18F7F1CFB4561995F6C76A8BE7F73-E8 --provisioning-token=46891A35"

#Starting Falcon sensor
if [[ -L "/sbin/init" ]]
then
    sudo bash -c "systemctl start falcon-sensor"
else
    sudo bash -c "service falcon-sensor start"
fi
cd /var/tmp

# Verification
if [[ -n $(ps -e | grep falcon-sensor) ]]
then
  echo "Successfully finished installation..."
else
  echo "Installation failed..."
  exit 1
fi

EOF
  )
}

# - - - CLUSTER LAUNCH TEMPLATE - - - #
resource "aws_launch_template" "k3-cluster-arm-iac" {
  name_prefix            = "k3-cluster-arm-iac"
  image_id               = "ami-0a02316a96c5435f5" # Belum ada AMI
  instance_type          = "m6g.large"
  key_name = "kairos-prod-key"
  vpc_security_group_ids = [aws_security_group.k3-asg-sg.id]
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      # Size of the EBS volume in GB
      volume_size = 30
      
      # Type of EBS volume (General Purpose SSD in this case)
      volume_type = "gp3"

      encrypted = true
      kms_key_id = "arn:aws:kms:ap-southeast-3:387413415276:key/7b09bd59-8a20-4de4-8008-84a351688670" #KMS EBS
    }
  }

    instance_market_options {
    market_type = "spot"
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  tag_specifications {
    resource_type = "instance"
    tags          = {
      "map-migrated" = "migXE6ORY1HAF"
    }
  }
  tag_specifications {
    resource_type = "volume"
    tags          = {
        "AppOwner"     = "Kairos"
        "DepartmentID" = "Kairos"
        "Environment"  = "prod"
        "Owner"        = "Kairos"
        "OwnerTeam"    = "Kairos"
        "map-migrated" = "migXE6ORY1HAF"
        "name"         = "k3-cluster-asg-arm-iac"
    }
  }

  iam_instance_profile { arn = "arn:aws:iam::387413415276:instance-profile/ECSInstanceRole" }
  monitoring { enabled = true }

user_data = base64encode(<<-EOF
#!/bin/bash
echo ECS_CLUSTER=${aws_ecs_cluster.cluster_prod.name} >> /etc/ecs/ecs.config;
# Install CloudWatch Agent
sudo yum install amazon-cloudwatch-agent -y

# Configure CloudWatch Agent for memory metrics
cat << 'EOF_CONFIG' > /opt/aws/amazon-cloudwatch-agent/bin/config.json
{
 "agent": {
  "metrics_collection_interval": 60,
  "run_as_user": "cwagent"
 },
 "metrics": {
  "aggregation_dimensions": [
   [
    "InstanceId"
   ]
  ],
  "append_dimensions": {
   "AutoScalingGroupName": "$${aws:AutoScalingGroupName}",
   "ImageId": "$${aws:ImageId}",
   "InstanceId": "$${aws:InstanceId}",
   "InstanceType": "$${aws:InstanceType}"
  },
  "metrics_collected": {
   "collectd": {
    "metrics_aggregation_interval": 60
   },
   "disk": {
    "measurement": [
     "used_percent"
    ],
    "metrics_collection_interval": 60,
    "resources": [
     "*"
    ]
   },
   "mem": {
    "measurement": [
     "mem_used_percent"
    ],
    "metrics_collection_interval": 60
   },
   "statsd": {
    "metrics_aggregation_interval": 60,
    "metrics_collection_interval": 10,
    "service_address": ":8125"
   }
  }
 }
}
EOF_CONFIG


# Start CloudWatch Agent
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json -s


sudo bash -c "eval /opt/CrowdStrike/falconctl -s --cid=5AC18F7F1CFB4561995F6C76A8BE7F73-E8 --provisioning-token=46891A35"

#Starting Falcon sensor
if [[ -L "/sbin/init" ]]
then
    sudo bash -c "systemctl start falcon-sensor"
else
    sudo bash -c "service falcon-sensor start"
fi
cd /var/tmp

# Verification
if [[ -n $(ps -e | grep falcon-sensor) ]]
then
  echo "Successfully finished installation..."
else
  echo "Installation failed..."
  exit 1
fi

EOF
  )
}


# --- CLUSTER prod ASG ---
resource "aws_autoscaling_group" "k3-cluster-asg-iac" {
  name                      = "k3-cluster-asg-iac"
  vpc_zone_identifier       = ["subnet-092c7acfd0ca847a1", "subnet-065675c9892dc6068", "subnet-0a4c5be8c1c9f6c77"]
  desired_capacity          = 20
  min_size                  = 0
  max_size                  = 40
  health_check_grace_period = 300
  health_check_type         = "EC2"
  protect_from_scale_in     = false

  lifecycle {
        ignore_changes = [ "desired_capacity"]
    }

  launch_template {
    id      = aws_launch_template.k3-cluster-temp-iac.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "k3-cluster-asg-iac"
    propagate_at_launch = true
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = ""
    propagate_at_launch = true
  }

  tag {
    key                 = "AppOwner"
    value               = "Kairos"
    propagate_at_launch = true
  }

  tag {
    key                 = "OwnerTeam"
    value               = "Kairos"
    propagate_at_launch = true
  }

  tag {
    key                 = "code-app"
    value               = "k3"
    propagate_at_launch = true
  }

  tag {
    key                 = "map-migrated"
    value               = "migXE6ORY1HAF"
    propagate_at_launch = true
  }
  
  tag {
    key                 = "Asg-Auto-Infra-k3-cluster-asg-iac"
    value               = "True"
    propagate_at_launch = true
  }
}

# --- CLUSTER DEV ASG ARM ---
resource "aws_autoscaling_group" "k3-cluster-arm-asg-iac" {
  name                      = "k3-cluster-arm-asg-iac"
  vpc_zone_identifier       = var.private_subnet_ids
  desired_capacity          = 1
  min_size                  = 0
  max_size                  = 40
  health_check_grace_period = 300
  health_check_type         = "EC2"
  protect_from_scale_in     = false

  launch_template {
    id      = aws_launch_template.k3-cluster-arm-iac.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "k3-cluster-asg-arm-iac"
    propagate_at_launch = true
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = ""
    propagate_at_launch = true
  }

  tag {
    key                 = "AppOwner"
    value               = "Kairos"
    propagate_at_launch = true
  }

  tag {
    key                 = "OwnerTeam"
    value               = "Kairos"
    propagate_at_launch = true
  }

  tag {
    key                 = "code-app"
    value               = "k3"
    propagate_at_launch = true
  }

  tag {
    key                 = "map-migrated"
    value               = "migXE6ORY1HAF"
    propagate_at_launch = true
  }
  
  tag {
    key                 = "Asg-Auto-Infra-k3-cluster-arm-asg-iac"
    value               = "True"
    propagate_at_launch = true
  }
}


resource "aws_autoscaling_policy" "cluster-pas-cpu-policy-up" {
  name                   = "cluster-pas-cpu-policy-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.k3-cluster-asg-iac.name
}

resource "aws_autoscaling_policy" "cluster-pas-mem-policy-up" {
  name                   = "cluster-pas-mem-policy-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.k3-cluster-asg-iac.name
}

resource "aws_autoscaling_policy" "cluster-pas-cpu-arm-policy-up" {
  name                   = "cluster-pas-cpu-arm-policy-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.k3-cluster-arm-asg-iac.name
}

resource "aws_autoscaling_policy" "cluster-pas-mem-arm-policy-up" {
  name                   = "cluster-pas-mem-arm-policy-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.k3-cluster-arm-asg-iac.name
}

resource "aws_ecs_account_setting_default" "this" {
  name  = "awsvpcTrunking"
  value = "enabled"
}

resource "aws_cloudwatch_metric_alarm" "cluster-pas-cpu-alarm-up" {
  alarm_name          = "cluster-pas-cpu-alarm-up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 70

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.k3-cluster-asg-iac.name
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.cluster-pas-cpu-policy-up.arn]
}

resource "aws_cloudwatch_metric_alarm" "cluster-pas-arm-cpu-alarm-up" {
  alarm_name          = "cluster-pas-arm-cpu-alarm-up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 70

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.k3-cluster-arm-asg-iac.name
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.cluster-pas-cpu-arm-policy-up.arn]
}

# Define CloudWatch log group for ECS cluster
resource "aws_cloudwatch_log_group" "ecs_cluster_log_group" {
  name              = "/aws/ecs/k3-asg-iac"
  retention_in_days = 7
}

# Define CloudWatch log metric filter for memory usage
resource "aws_cloudwatch_log_metric_filter" "memory_metric_filter" {
  name           = "MemoryUsageFilter"
  pattern        = "{ $.detail.additionalMetrics.memoryUsage >= 80 }" 
  log_group_name = aws_cloudwatch_log_group.ecs_cluster_log_group.name

  metric_transformation {
    name      = "MemoryUsageMetric"
    namespace = "Test/EC2"  
    value     = "$.detail.additionalMetrics.memoryUsage"
  }
}

# Set up a CloudWatch alarm to monitor memory usage
resource "aws_cloudwatch_metric_alarm" "memory_alarm" {
  alarm_name          = "cluster-pas-memory-alarm-up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "MemoryUsageMetric"  
  namespace           = "CWAgent"  
  period              = 300                   
  statistic           = "Maximum"             
  threshold           = 80    

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.k3-cluster-asg-iac.name
  }
                  
  alarm_description   = "This alarm triggers when memory usage is above 80% for 2 periods of 5 minutes each"
  alarm_actions       = [aws_autoscaling_policy.cluster-pas-mem-policy-up.arn]   
}

resource "aws_cloudwatch_metric_alarm" "memory_arm_alarm" {
  alarm_name          = "cluster-pas-arm-memory-alarm-up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "MemoryUsageMetric"  
  namespace           = "CWAgent"  
  period              = 300                   
  statistic           = "Maximum"             
  threshold           = 80    

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.k3-cluster-arm-asg-iac.name
  }
                  
  alarm_description   = "This alarm triggers when memory usage is above 80% for 2 periods of 5 minutes each"
  alarm_actions       = [aws_autoscaling_policy.cluster-pas-mem-arm-policy-up.arn]   
}

# --- ECS Capacity Provider to connect the ECS Cluster to the ASG group ---
resource "aws_ecs_capacity_provider" "caprov_prod" {
  name = "cp_pas_prod"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.k3-cluster-asg-iac.arn
    //arn diatas ambil dari existing yang sudah di create
    managed_termination_protection = "DISABLED"

    managed_scaling {
      maximum_scaling_step_size = 10
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 80
    }
  }
}

resource "aws_ecs_capacity_provider" "caprov_arm_prod" {
  name = "cp_pas_arm_prod"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.k3-cluster-arm-asg-iac.arn
    //arn diatas ambil dari existing yang sudah di create
    managed_termination_protection = "DISABLED"

    managed_scaling {
      maximum_scaling_step_size = 10
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 80
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "cp_to_ecs_prod" {
  cluster_name       = "k3-cluster-ecs-iac"
  capacity_providers = [aws_ecs_capacity_provider.caprov_prod.name, aws_ecs_capacity_provider.caprov_arm_prod.name]

  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.caprov_prod.name
    base              = 0
    weight            = 1
  }

    default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.caprov_arm_prod.name
    base              = 0
    weight            = 0
  }
}
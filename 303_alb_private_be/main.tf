locals {
  certificate_arn = "arn:aws:acm:ap-southeast-3:235494785181:certificate/81675b4a-ac07-461d-8122-f3984766b484"
  vpc_id            =  "vpc-0c6e322ba7308224f"
  subnet_ids        = ["subnet-0d8f73b36c979812f", "subnet-08f5684f0d529384b"]
  bucket_name       = "log-k3-be-lb-alb-internal-iac"
  bucket_name_conn  = "log-conn-k3-be-lb-alb-internal-iac"
  aws_account_id    = "235494785181"
}

resource "aws_security_group" "alb_sg_prod" {
  name    = "k3-be-lb-alb-internal-sg-iac"
  description = "Load Balancer security group for Cluster k3 BE"
  vpc_id  =  "vpc-0c6e322ba7308224f"

  ingress {
      description     = "Allow All Traffic from Private & Protected A"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      cidr_blocks     = ["10.100.70.0/26", "10.100.70.160/27"]
    }

    ingress {
      description     = "Allow All Traffic from Private & Protected B"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      cidr_blocks     = ["10.100.70.64/26", "10.100.70.192/27"]
    }

    ingress {
      description     = "Allow All Traffic from HO"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      cidr_blocks     = ["10.1.128.0/18"]
    }

    ingress {
      description     = "Allow All Traffic from K3 Prod"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      cidr_blocks     = ["10.100.70.0/24"]
    }

    ingress {
      description     = "Allow All Traffic from Unit"
      from_port       = 4000
      to_port         = 4100
      protocol        = "tcp"
      cidr_blocks     = ["10.0.0.0/8"]
    }

    ingress {
      description     = "Allow All Traffic from Unit"
      from_port       = 5000
      to_port         = 5999
      protocol        = "tcp"
      cidr_blocks     = ["10.0.0.0/8"]
    }

    ingress {
      description     = "Allow All Traffic from Unit"
      from_port       = 7000
      to_port         = 7999
      protocol        = "tcp"
      cidr_blocks     = ["10.0.0.0/8"]
    }

    ingress {
      description     = "Allow All Traffic from Unit"
      from_port       = 9000
      to_port         = 9999
      protocol        = "tcp"
      cidr_blocks     = ["10.0.0.0/8"]
    }
  
ingress {
      description     = "Allow All Traffic from Unit"
      from_port       = 443
      to_port         = 443
      protocol        = "tcp"
      cidr_blocks     = ["10.0.0.0/8"]
    }

  egress {
      description     = "Allow All Traffic"
      from_port       = 0
      to_port         = 0
      protocol        = -1
      cidr_blocks     = ["0.0.0.0/0"]
    }
}

#### S3 alb ACCESS LOG #####
####################################
module "s3_bucket-log-k3-be-lb-nlb-internal-iac" {
  source = "./../modules/s3_bucket/v1"

  bucket_name = local.bucket_name

  enable_log_bucket = false
  enable_versioning = true

  bucket_policy = <<EOT
    {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::589379963580:root"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::${local.bucket_name}/*"
        },
        {
            "Sid": "AllowSSLRequestsOnly",
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::${local.bucket_name}",
                "arn:aws:s3:::${local.bucket_name}/*"
            ],
            "Condition": {
                "Bool": {
                    "aws:SecureTransport": "false"
                }
            }
        }
      ]
    }
  EOT
}

#### S3 alb COnnection LOG #####
####################################
module "s3_bucket-log-conn-k3-be-lb-nlb-internal-iac" {
  source = "./../modules/s3_bucket/v1"

  bucket_name = local.bucket_name_conn

  enable_log_bucket = false
  enable_versioning = true

  bucket_policy = <<EOT
    {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::589379963580:root"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::${local.bucket_name_conn}/*"
        },
        {
            "Sid": "AllowSSLRequestsOnly",
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::${local.bucket_name_conn}",
                "arn:aws:s3:::${local.bucket_name_conn}/*"
            ],
            "Condition": {
                "Bool": {
                    "aws:SecureTransport": "false"
                }
            }
        }
      ]
    }
  EOT
}

#### Application Load Balancer #####
####################################
module "alb_private" {
  source = "./../modules/alb/v2"

  name = "k3-be-lb-alb-internal-iac"

  load_balancer_type = "application"

  security_groups = [aws_security_group.alb_sg_prod.id]

  subnets = local.subnet_ids

  vpc_id = local.vpc_id

  enable_deletion_protection = false

  internal = true

  enable_cross_zone_load_balancing = true

  enforce_security_group_inbound_rules_on_private_link_traffic = "off"

  # add alb logging 
  access_logs = {
    bucket = "${local.bucket_name}"
    prefix = ""
  }

  connection_logs = {
    bucket = "${local.bucket_name_conn}"
  }

  # DEFAULT and LAST PRIORITY of ROUTE
  http_tcp_listeners = [{
    port               = 80
    protocol           = "HTTP"
    action_type        = "forward"
    target_group_index = 0
  }]

  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = local.certificate_arn
      target_group_index = 0
    }
  ]

  target_groups = [
    {
      name             = "dummy-tg" #0
      backend_port     = 80
      backend_protocol = "http"
      protocol_version = "HTTP1"
      target_type      = "instance"
    },
    {
      name             = "k3-be-main-web-tg-iac" #1 
      backend_port     = 3000
      backend_protocol = "HTTP"
      target_type      = "ip"
      health_check = {
        enabled  = true
        interval = "30"
        path     = "/"
        matcher  = "200"
        protocol = "HTTP"
      }
    },
    {
      name             = "k3-worker-tg-iac" #2 
      backend_port     = 9902
      backend_protocol = "HTTP"
      target_type      = "ip"
      health_check = {
        enabled  = true
        interval = "30"
        path     = "/"
        matcher  = "200"
        protocol = "HTTP"
      }
    },
    {
      name             = "k3-apm-tg-iac" #3 
      backend_port     = 80
      backend_protocol = "HTTP"
      target_type      = "ip"
      health_check = {
        enabled  = true
        interval = "30"
        path     = "/apm/"
        matcher  = "200"
        protocol = "HTTP"
      }
      targets = {
        apm = {
          target_id         = "10.100.70.109"
          port              = 80
          availability_zone = "ap-southeast-3b"
        }
      }
    },
      {
      name             = "k3-web-ui-tg-iac" #4 
      backend_port     = 7700
      backend_protocol = "HTTP"
      target_type      = "ip"
      health_check = {
        enabled  = true
        interval = "30"
        path     = "/"
        matcher  = "200"
        protocol = "HTTP"
      }
      }
  ]

  http_tcp_listener_rules = [
    {
      http_tcp_listener_index = 0
      priority                = 32
      actions = [{
        type        = "redirect"
        status_code = "HTTP_301"
        host        = "#{host}"
        port        = "443"
        path        = "/#{path}"
        query       = "#{query}"
        protocol    = "HTTPS"
      }]

      conditions = [
        {
          host_headers = ["*.siloamhospitals.com"]
        },
      ]
    }
  ]

  https_listener_rules = [
    {
      https_listener_index = 0
      priority             = 93

      actions = [{
        type               = "forward"
        target_group_index = 1
        stickiness = {
          enabled = false
        }
      }]

      conditions = [{
        host_headers = ["api-hsse.siloamhospitals.com"] #01
        },
      ]
    },
    {
      https_listener_index = 0
      priority             = 94

      actions = [{
        type               = "forward"
        target_group_index = 2
        stickiness = {
          enabled = false
        }
      }]

      conditions = [{
        host_headers = ["prod-worker.siloamhospitals.com"] #2
        },
      ]
    },
    {
      https_listener_index = 0
      priority             = 95

      actions = [{
        type               = "forward"
        target_group_index = 3
        stickiness = {
          enabled = false
        }
      }]

      conditions = [{
        host_headers = ["prod-apm-k3.siloamhospitals.com"] #3
        },
      ]
    },
    {
      https_listener_index = 0
      priority             = 92

      actions = [{
        type               = "forward"
        target_group_index = 4
        stickiness = {
          enabled = false
        }
      }]

      conditions = [{
        host_headers = ["prod-k3-web-ui.siloamhospitals.com"] #4
        },
        ]
      }
  ]
}

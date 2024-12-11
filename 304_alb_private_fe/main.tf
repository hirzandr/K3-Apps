locals {
  certificate_arn = "arn:aws:acm:ap-southeast-3:235494785181:certificate/81675b4a-ac07-461d-8122-f3984766b484"
  vpc_id            =  var.vpc_id
  subnet_ids        = var.private_subnet_ids
  bucket_name       = "log-k3-fe-prod-lb-alb-internal-iac"
  bucket_name_conn  = "log-conn-k3-fe-prod-lb-alb-internal-iac"
  aws_account_id    = "235494785181"
}

resource "aws_security_group" "alb_sg_prod_fe" {
  name    = "k3-fe-prod-lb-alb-internal-sg-iac"
  description = "Load Balancer security group for K3 FE"
  vpc_id  =  var.vpc_id

   ingress {
      description     = "Allow All Traffic from VPC"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      cidr_blocks     = ["10.100.70.0/24"]
    }

    ingress {
      description     = "Allow All Traffic from HO"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      cidr_blocks     = ["10.1.128.0/18"]
    }

    # ingress {
    #   description     = "Allow All Traffic from MySiloam uat"
    #   from_port       = 0
    #   to_port         = 0
    #   protocol        = "-1"
    #   cidr_blocks     = ["10.100.196.0/22"]
    # }
  
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
module "s3_bucket-log-k3-fe-lb-nlb-internal-iac" {
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
module "s3_bucket-log-conn-k3-fe-lb-nlb-internal-iac" {
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

  name = "k3-fe-prod-lb-alb-internal-iac"

  load_balancer_type = "application"

  security_groups = [aws_security_group.alb_sg_prod_fe.id]

  subnets = local.subnet_ids

  vpc_id = local.vpc_id

  enable_deletion_protection = true

  internal = true

  enable_cross_zone_load_balancing = true

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
      name             = "dummy-tg3" #00
      backend_port     = 80
      backend_protocol = "http"
      protocol_version = "HTTP1"
      target_type      = "instance"
    },
    {
      name             = "k3-fe-main-web-tg-iac" #1 
      backend_port     = 9901
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
  ]

  http_tcp_listener_rules = [ #00
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


  https_listener_rules = [ #01
    {
      https_listener_index = 0
      priority             = 93

      actions = [{
        type               = "forward"
        target_group_index = 1
        stickiness = {
          enabled = false
          #duration = 3600
        }
      }]
      conditions = [{
        host_headers = ["prod-k3-api-integration.siloamhospitals.com"]
        },
      ]
    }
  ]
}

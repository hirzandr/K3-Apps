locals {
  certificate_arn = "arn:aws:acm:ap-southeast-3:387413415276:certificate/0375aa5c-03e0-4ef5-8490-834ec85586b0"
  vpc_id            =  "vpc-079fbf10a5eb9468f"
  subnet_ids        = ["subnet-092c7acfd0ca847a1", "subnet-065675c9892dc6068", "subnet-0a4c5be8c1c9f6c77"]
  bucket_name       = "log-kairos-fe-lb-alb-internal-iac"
  bucket_name_conn  = "log-conn-kairos-fe-lb-alb-internal-iac"
  aws_account_id    = "387413415276"
}

resource "aws_security_group" "alb_sg_preprod" {
  name    = "kairos-fe-lb-alb-internal-sg-iac"
  description = "Load Balancer security group for Cluster Kairos FE"
  vpc_id  =  "vpc-079fbf10a5eb9468f"

  ingress {
      description     = "Allow All Traffic from Private & Protected"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      cidr_blocks     = ["10.100.210.0/24"]
    }

    ingress {
      description     = "Allow All Traffic from Private & Protected"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      cidr_blocks     = ["10.100.211.128/26"]
    }

    ingress {
      description     = "Allow All Traffic from Private & Protected"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      cidr_blocks     = ["10.100.211.64/26"]
    }

    ingress {
      description     = "Allow All Traffic from Private & Protected"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      cidr_blocks     = ["10.100.209.0/24"]
    }

    ingress {
      description     = "Allow All Traffic from Private & Protected"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      cidr_blocks     = ["10.100.211.0/26"]
    }

    ingress {
      description     = "Allow All Traffic from Private & Protected"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      cidr_blocks     = ["10.100.208.0/24"]
    }

    ingress {
      description     = "Allow All Traffic from HO"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      cidr_blocks     = ["10.1.128.0/18"]
    }

    ingress {
      description     = "Allow All Traffic from MySiloam Preprod"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      cidr_blocks     = ["10.100.196.0/22"]
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
module "s3_bucket-log-kairos-fe-lb-nlb-internal-iac" {
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
module "s3_bucket-log-conn-kairos-fe-lb-nlb-internal-iac" {
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

  name = "kairos-fe-lb-alb-internal-iac"

  load_balancer_type = "application"

  security_groups = [aws_security_group.alb_sg_preprod.id]

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
    {#0
      name             = "dummy-tg"
      backend_port     = 80
      backend_protocol = "http"
      protocol_version = "HTTP1"
      target_type      = "instance"
    },
    {#1 
      name             = "pas-kairos-fe-main-web-tg-iac"
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
    {#2 
      name             = "pay-kairos-ui-tg-iac"
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
    {#3 
      name             = "apm-tg-iac"
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
          target_id         = "10.100.3.7"
          port              = 80
          availability_zone = "all"
        }
      }
    },
      {#4 
      name             = "kairos-web-ui-tg-iac"
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
        host_headers = ["preprd-pas-kairos.siloamhospitals.com"]
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
        host_headers = ["preprd-pay-kairos.siloamhospitals.com"]
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
        host_headers = ["preprd-apm-kairos.siloamhospitals.com"]
        },
      ]
    },
#    {
#      https_listener_index = 0
#      priority             = 94
#
#      actions = [{
#        type               = "forward"
#        target_group_index = 2
#        stickiness = {
#          enabled = false
#        }
#      }]
#
#      conditions = [{
#        host_headers = ["preprd-pay-kairos.siloamhospitals.com"]
#        },
#      ]
#    },
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
        host_headers = ["preprd-kairos.siloamhospitals.com"]
        },
        ]
      },
  ]
}

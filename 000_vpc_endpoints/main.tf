###############################
############ ECS ##############
###############################
resource "aws_security_group" "endpoint-ecs-sg-iac" {

  name        = "endpoint-ecs-sg-iac"
  description = "Security Group  for VPC Endpoint ECS"
  vpc_id      = var.vpc_id

  ingress {
      description     = "Allow All Traffic from VPC"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      cidr_blocks     = ["10.100.70.0/24"]
    }
  
  egress {
      description     = "Allow All Traffic from VPC"
      from_port       = 0
      to_port         = 0
      protocol        = -1
      cidr_blocks     = ["10.100.70.0/24"]
    }
}

resource "aws_vpc_endpoint" "ecs" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.ap-southeast-3.ecs"
  vpc_endpoint_type = "Interface"

  security_group_ids = [aws_security_group.endpoint-ecs-sg-iac.id]

  subnet_ids        = var.private_subnet_ids

  private_dns_enabled = true

  tags = {
    Name = "ecs-endpoint-iac"
  }
}

###############################
######### ECS Agent ###########
###############################
resource "aws_security_group" "endpoint-ecs-agent-sg-iac" {

  name        = "endpoint-ecs-agent-sg-iac"
  description = "Security Group for VPC Endpoint ECS Agent"
  vpc_id      = var.vpc_id

  ingress {
      description     = "Allow All Traffic from VPC"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      cidr_blocks     = ["10.100.70.0/24"]
    }
  
  egress {
      description     = "Allow All Traffic from VPC"
      from_port       = 0
      to_port         = 0
      protocol        = -1
      cidr_blocks     = ["10.100.70.0/24"]
    }
}

resource "aws_vpc_endpoint" "ecs-agent" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.ap-southeast-3.ecs-agent"
  vpc_endpoint_type = "Interface"

  security_group_ids = [aws_security_group.endpoint-ecs-agent-sg-iac.id]

  subnet_ids        = var.private_subnet_ids

  private_dns_enabled = true

  tags = {
    Name = "ecs-agent-endpoint-iac"
  }
}

###############################
########## ECR API ############
###############################
resource "aws_security_group" "endpoint-ecr-api-sg-iac" {

  name        = "endpoint-ecr-api-sg-iac"
  description = "Security Group for VPC Endpoint ECR API"
  vpc_id      = var.vpc_id

  ingress {
      description     = "Allow All Traffic from VPC"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      cidr_blocks     = ["10.100.70.0/24"]
    }
  
  egress {
      description     = "Allow All Traffic from VPC"
      from_port       = 0
      to_port         = 0
      protocol        = -1
      cidr_blocks     = ["10.100.70.0/24"]
    }
}

resource "aws_vpc_endpoint" "ecr-api" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.ap-southeast-3.ecr.api"
  vpc_endpoint_type = "Interface"

  security_group_ids = [aws_security_group.endpoint-ecr-api-sg-iac.id]

  subnet_ids        = var.private_subnet_ids

  private_dns_enabled = true

  tags = {
    Name = "ecr-api-endpoint-iac"
  }
}

###############################
########## ECR DKR ############
###############################
resource "aws_security_group" "endpoint-ecr-dkr-sg-iac" {

  name        = "endpoint-ecr-dkr-sg-iac"
  description = "Security Group for VPC Endpoint ECR DKR"
  vpc_id      = var.vpc_id

  ingress {
      description     = "Allow All Traffic from VPC"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      cidr_blocks     = ["10.100.70.0/24"]
    }
  
  egress {
      description     = "Allow All Traffic from VPC"
      from_port       = 0
      to_port         = 0
      protocol        = -1
      cidr_blocks     = ["10.100.70.0/24"]
    }
}

resource "aws_vpc_endpoint" "ecr-dkr" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.ap-southeast-3.ecr.dkr"
  vpc_endpoint_type = "Interface"

  security_group_ids = [aws_security_group.endpoint-ecr-dkr-sg-iac.id]

  subnet_ids        = var.private_subnet_ids

  private_dns_enabled = true

  tags = {
    Name = "ecr-dkr-endpoint-iac"
  }
}

###############################
######### CLOUDWATCH ##########
###############################
resource "aws_security_group" "endpoint-cloudwatch-sg-iac" {

  name        = "endpoint-cloudwatch-sg-iac"
  description = "Security Group for VPC Endpoint CloudWatch"
  vpc_id      = var.vpc_id

  ingress {
      description     = "Allow All Traffic from VPC"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      cidr_blocks     = ["10.100.70.0/24"]
    }
  
  egress {
      description     = "Allow All Traffic from VPC"
      from_port       = 0
      to_port         = 0
      protocol        = -1
      cidr_blocks     = ["10.100.70.0/24"]
    }
}

resource "aws_vpc_endpoint" "cloudwatch" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.ap-southeast-3.logs"
  vpc_endpoint_type = "Interface"

  security_group_ids = [aws_security_group.endpoint-cloudwatch-sg-iac.id]

  subnet_ids        = var.private_subnet_ids

  private_dns_enabled = true

  tags = {
    Name = "cloudwatch-endpoint-iac"
  }
}

###############################
########### RDS ###############
###############################
resource "aws_security_group" "endpoint-rds-sg-iac" {

  name        = "endpoint-rds-sg-iac"
  description = "Security Group for VPC Endpoint RDS"
  vpc_id      = var.vpc_id

  ingress {
      description     = "Allow All Traffic from VPC"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      cidr_blocks     = ["10.100.70.0/24"]
    }
  
  egress {
      description     = "Allow All Traffic from VPC"
      from_port       = 0
      to_port         = 0
      protocol        = -1
      cidr_blocks     = ["10.100.70.0/24"]
    }
}

resource "aws_vpc_endpoint" "rds" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.ap-southeast-3.rds"
  vpc_endpoint_type = "Interface"

  security_group_ids = [aws_security_group.endpoint-rds-sg-iac.id]

  subnet_ids        = var.private_subnet_ids

  private_dns_enabled = true

  tags = {
    Name = "rds-endpoint-iac"
  }
}

###############################
#### Secret Manager ###########
###############################
resource "aws_security_group" "endpoint-secretmanager-sg-iac" {

  name        = "endpoint-secretmanager-sg-iac"
  description = "Security Group for VPC Endpoint Secret Manager"
  vpc_id      = var.vpc_id

  ingress {
      description     = "Allow All Traffic from VPC"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      cidr_blocks     = ["10.100.70.0/24"]
    }
  
  egress {
      description     = "Allow All Traffic from VPC"
      from_port       = 0
      to_port         = 0
      protocol        = -1
      cidr_blocks     = ["10.100.70.0/24"]
    }
}

resource "aws_vpc_endpoint" "secretmanager" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.ap-southeast-3.secretsmanager"
  vpc_endpoint_type = "Interface"

  security_group_ids = [aws_security_group.endpoint-secretmanager-sg-iac.id]

  subnet_ids        = var.private_subnet_ids

  private_dns_enabled = true

  tags = {
    Name = "secretmanager-endpoint-iac"
  }
}

###############################
####### API Gateway ###########
###############################
resource "aws_security_group" "endpoint-api-gateway-sg-iac" {

  name        = "endpoint-api-gateway-sg-iac"
  description = "Security Group for VPC Endpoint API Gateway"
  vpc_id      = var.vpc_id

  ingress {
      description     = "Allow All Traffic from VPC"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      cidr_blocks     = ["10.100.70.0/24"]
    }
  
  egress {
      description     = "Allow All Traffic from VPC"
      from_port       = 0
      to_port         = 0
      protocol        = -1
      cidr_blocks     = ["10.100.70.0/24"]
    }
}

resource "aws_vpc_endpoint" "api-gateway" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.ap-southeast-3.execute-api"
  vpc_endpoint_type = "Interface"

  security_group_ids = [aws_security_group.endpoint-api-gateway-sg-iac.id]

  subnet_ids        = var.private_subnet_ids

  private_dns_enabled = true

  tags = {
    Name = "api-gateway-endpoint-iac"
  }
}


###############################
############# SSM #############
###############################
resource "aws_security_group" "endpoint-ssm-sg-iac" {

  name        = "endpoint-ssm-sg-iac"
  description = "Security Group for VPC Endpoint SSM"
  vpc_id      = var.vpc_id

  ingress {
      description     = "Allow All Traffic from VPC"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      cidr_blocks     = ["10.100.70.0/24"]
    }
  
  egress {
      description     = "Allow All Traffic from VPC"
      from_port       = 0
      to_port         = 0
      protocol        = -1
      cidr_blocks     = ["10.100.70.0/24"]
    }
}

resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.ap-southeast-3.ssmmessages"
  vpc_endpoint_type = "Interface"

  security_group_ids = [aws_security_group.endpoint-ssm-sg-iac.id]

  subnet_ids        = var.private_subnet_ids

  private_dns_enabled = true

  tags = {
    Name = "ssmmessages-endpoint-iac"
  }
}

resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.ap-southeast-3.ec2messages"
  vpc_endpoint_type = "Interface"

  security_group_ids = [aws_security_group.endpoint-ssm-sg-iac.id]

  subnet_ids        = var.private_subnet_ids

  private_dns_enabled = true

  tags = {
    Name = "ec2messages-endpoint-iac"
  }
}

resource "aws_vpc_endpoint" "ssm" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.ap-southeast-3.ssm"
  vpc_endpoint_type = "Interface"

  security_group_ids = [aws_security_group.endpoint-ssm-sg-iac.id]

  subnet_ids        = var.private_subnet_ids

  private_dns_enabled = true

  tags = {
    Name = "ssm-endpoint-iac"
  }
}

###############################
###### ECS Telemetry ##########
###############################
resource "aws_security_group" "endpoint-ecs-telemetry-sg-iac" {

  name        = "endpoint-ecs-telemetry-sg-iac"
  description = "Security Group for VPC Endpoint SSM"
  vpc_id      = var.vpc_id

  ingress {
      description     = "Allow All Traffic from VPC"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      cidr_blocks     = ["10.100.70.0/24"]
    }
  
  egress {
      description     = "Allow All Traffic from VPC"
      from_port       = 0
      to_port         = 0
      protocol        = -1
      cidr_blocks     = ["10.100.70.0/24"]
    }
}

resource "aws_vpc_endpoint" "ecs-telemetry" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.ap-southeast-3.ecs-telemetry"
  vpc_endpoint_type = "Interface"

  security_group_ids = [aws_security_group.endpoint-ecs-telemetry-sg-iac.id]

  subnet_ids        = var.private_subnet_ids

  private_dns_enabled = true

  tags = {
    Name = "ecs-telemetry-endpoint-iac"
  }
}
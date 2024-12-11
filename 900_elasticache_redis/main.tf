module "k3-redis-sg" {
  source = "./../modules/security_group/v1"

  name        = "k3-redis-sg-iac"
  description = "Security group for k3 Redis"
  vpc_id      =  var.vpc_id

  ingress_rules = [
    {
      description     = "Allow Traffic from HO"
      from_port       = 0
      to_port         = 0
      protocol        = -1
      security_groups = []
      cidr_blocks = ["10.1.128.0/18"]
    },
    {
      description     = "Allow All Traffic from VPC"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      security_groups = []
      cidr_blocks     = ["10.100.70.0/24"]
    },
  ]
  egress_rules = [
    {
      description     = "Allow Traffic to Internet"
      from_port       = 0
      to_port         = 0
      protocol        = "ALL"
      cidr_blocks     = ["0.0.0.0/0"]
      security_groups = []
    }
  ]
}

# SUBNET GROUP
resource "aws_elasticache_subnet_group" "prod-sg" {
  name        = "k3-cache-subnet-group"
  description = "k3 Cache Subnet Group"
  subnet_ids  = ["subnet-047d6d54dfc282fb9","subnet-0959b31f461a57710"] #SUBNET PROTECTED
}

# PARAMETER GROUP
resource "aws_elasticache_parameter_group" "prod-pg" {
  name          = "k3-cache-params"
  description   = "k3 Cache Parameter Group"
  family        = "redis7"
}

# CACHE
resource "aws_elasticache_cluster" "k3-redis" {
  cluster_id           = "k3-cache"
  engine               = "redis"
  node_type            = "cache.t3.small"
  num_cache_nodes      = 1
  parameter_group_name = aws_elasticache_parameter_group.prod-pg.name
  engine_version       = "7.1"
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.prod-sg.name
  security_group_ids   = [module.k3-redis-sg.security_group_id]
}
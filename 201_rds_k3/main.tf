/*create security group di existing VPC*/
resource "aws_security_group" "rds_sg_prod" {
  name   = "k3-rds-prod-db-sg-iac"
  vpc_id = var.vpc_id

  ingress {
    description = "Allow Traffic PostgreSQL from Protected B"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.100.70.192/27"]
  }

  ingress {
    description = "Allow Traffic PostgreSQL from Private B"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.100.70.64/26"]
  }

  ingress {
    description = "Allow Traffic PostgreSQL from Private A"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.100.70.0/26"]
  }

  ingress {
    description = "Allow Traffic PostgreSQL from Protected A"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.100.70.160/27"]
  }

  ingress {
    description = "Allow Traffic from HO/VPN"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.1.128.0/18"]
  }

  ingress {
    description = "Allow From JumpHost-DB-HO"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [
      "10.1.8.76/32",
      "10.1.8.77/32"
    ]
  }
 /* 
  ingress {
    description     = "Allow Traffic from Bastion"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = ["sg-05dda5049ba54b427"]
  }

  ingress {
    description = "Allow Traffic Protected A"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.100.170.128/26"]
  }

  ingress {
    description = "Allow Traffic Protected B"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.100.170.192/26"]
  }
*/

  /*  IP 10.85.147.74 tempo hari di pakai untuk restore db kan ya om  Jajar ? Yg prod akan di restore dari ip yg sama?
    ingress {
      description     = "HIS-PGSQLDB-PREPRD-02"
      from_port       = 5432
      to_port         = 5432
      protocol        = "tcp"
      cidr_blocks     = ["10.85.147.74/32"]
    }
  */
  egress {
    description = "Allow Traffic"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

/*module pembuatan database rds postgresql*/
module "db_k3_prod_01" {
  source  = "terraform-aws-modules/rds/aws"
  version = "6.4.0"
  #define tipe, model, dan spesifikasi database
  identifier        = "k3-rds-prod-db-iac"
  engine            = "postgres"
  engine_version    = "15.5"
  license_model     = "postgresql-license"
  family            = "postgres15"
  instance_class    = "db.t3.xlarge"
  allocated_storage = 256
  storage_type      = "gp3"


  #define master user db dan port
  username = "postgres"
  port     = "5432"

  #add kms dari existing kms
  kms_key_id = "arn:aws:kms:ap-southeast-3:235494785181:key/5c28e9e6-1802-43ec-8407-50524ea207c6" #KMS RDS

  #attach subnet group, dan security group ke database rds
  create_db_subnet_group = false
  db_subnet_group_name   = "prod-k3-subnet-group"
  vpc_security_group_ids = [aws_security_group.rds_sg_prod.id]
  availability_zone = "ap-southeast-3a"
  




  #enable monitoring
  monitoring_interval    = "0"
  monitoring_role_name   = "K3RDSMonitoringRole"
  create_monitoring_role = true

  backup_retention_period = 1
  backup_window           = "10:00-11:00"

  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  maintenance_window                    = "Sat:13:41-Sat:14:11"
  auto_minor_version_upgrade            = false

  #informasi tagging
  db_instance_tags = {
    "Managed_Via"        = "TerraformManaged"
    "Owner"              = "K3"
    "Environment"        = "PROD"
    "compliance"         = "true"
    "OwnerTeam"          = "K3"
    "DepartmentID"       = "K3"
    "DataClassification" = "non-clinical"
    "ProvisionedBy"      = "Hirzan-SSE"
  }

  apply_immediately = true
  multi_az          = false
}


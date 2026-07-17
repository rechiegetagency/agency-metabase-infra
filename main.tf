locals {
  name_prefix = "agency-metabase-${var.environment}"

  # DB parameter group family follows the engine major version (e.g. "16" -> "postgres16").
  parameter_group_family = "postgres${split(".", var.engine_version)[0]}"
}

# By default (manage_master_user_password = true) RDS generates the master
# password and stores it in AWS Secrets Manager — it never touches Terraform
# state. Only when that is disabled do we fall back to a Terraform-generated
# password, which then lives in terraform.tfstate (treat state as a secret).
resource "random_password" "db" {
  count   = var.manage_master_user_password ? 0 : 1
  length  = 32
  special = false # avoid characters RDS disallows in master passwords (/, @, ", space)
}

resource "aws_db_subnet_group" "this" {
  name       = "${local.name_prefix}-db"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "${local.name_prefix}-db"
  }
}

resource "aws_security_group" "db" {
  name        = "${local.name_prefix}-db"
  description = "Controls access to the agency-metabase PostgreSQL instance"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${local.name_prefix}-db"
  }
}

resource "aws_vpc_security_group_ingress_rule" "from_cidr" {
  for_each = toset(var.allowed_cidr_blocks)

  security_group_id = aws_security_group.db.id
  description       = "PostgreSQL from ${each.value}"
  cidr_ipv4         = each.value
  from_port         = var.db_port
  to_port           = var.db_port
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "from_sg" {
  for_each = toset(var.allowed_security_group_ids)

  security_group_id            = aws_security_group.db.id
  description                  = "PostgreSQL from ${each.value}"
  referenced_security_group_id = each.value
  from_port                    = var.db_port
  to_port                      = var.db_port
  ip_protocol                  = "tcp"
}

# Metabase Cloud connects from outside the VPC via a fixed set of static IPs.
# We allow only those IPs to reach the database on the PostgreSQL port.
resource "aws_vpc_security_group_ingress_rule" "from_metabase_cloud" {
  for_each = toset(var.metabase_cloud_cidrs)

  security_group_id = aws_security_group.db.id
  description       = "PostgreSQL from Metabase Cloud ${each.value}"
  cidr_ipv4         = each.value
  from_port         = var.db_port
  to_port           = var.db_port
  ip_protocol       = "tcp"
}

# Force all client connections to use SSL/TLS.
resource "aws_db_parameter_group" "this" {
  name_prefix = "${local.name_prefix}-"
  family      = local.parameter_group_family
  description = "Parameters for ${local.name_prefix} (forces SSL)"

  parameter {
    name  = "rds.force_ssl"
    value = "1"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_db_instance" "metabase" {
  identifier     = local.name_prefix
  engine         = "postgres"
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = var.db_name
  username = var.db_username
  port     = var.db_port

  # Prefer RDS-managed credentials (Secrets Manager). Fall back to a
  # Terraform-generated password only when explicitly disabled.
  manage_master_user_password = var.manage_master_user_password ? true : null
  password                    = var.manage_master_user_password ? null : random_password.db[0].result

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.db.id]
  parameter_group_name   = aws_db_parameter_group.this.name

  # Metabase Cloud lives outside the VPC, so the instance must be reachable
  # from the internet. Exposure is restricted to Metabase Cloud's static IPs
  # by the security group above, and SSL is enforced via the parameter group.
  # Requires the DB subnet group to use PUBLIC subnets (route to an IGW).
  publicly_accessible = var.publicly_accessible

  multi_az                   = var.multi_az
  backup_retention_period    = var.backup_retention_period
  auto_minor_version_upgrade = true

  deletion_protection       = var.deletion_protection
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${local.name_prefix}-final"

  tags = {
    Name = local.name_prefix
  }
}

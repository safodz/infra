resource "aws_db_subnet_group" "main" {
  name       = "${var.name_prefix}-db-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-db-subnet-group"
    }
  )
}

resource "aws_db_instance" "main" {
  identifier = "${var.name_prefix}-db"

  engine         = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage     = var.allocated_storage
  max_allocated_storage  = var.max_allocated_storage
  storage_type          = var.storage_type
  storage_encrypted      = var.storage_encrypted
  kms_key_id            = var.kms_key_id

  db_name  = var.db_name
  username = var.username
  password = var.password

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = var.security_group_ids
  publicly_accessible     = var.publicly_accessible

  backup_retention_period = var.backup_retention_period
  backup_window          = var.backup_window
  maintenance_window     = var.maintenance_window

  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports

  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier  = var.final_snapshot_identifier
  deletion_protection        = var.deletion_protection
  performance_insights_enabled = var.performance_insights_enabled

  multi_az               = var.multi_az
  availability_zone      = var.multi_az ? null : var.availability_zone

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-db"
    }
  )
}

resource "aws_db_instance" "standby" {
  count = var.create_standby ? 1 : 0

  identifier = "${var.name_prefix}-db-standby"

  replicate_source_db = aws_db_instance.main.identifier

  instance_class = var.instance_class
  publicly_accessible = var.publicly_accessible

  vpc_security_group_ids = var.security_group_ids
  availability_zone      = var.standby_availability_zone

  skip_final_snapshot       = true
  deletion_protection       = false
  performance_insights_enabled = var.performance_insights_enabled

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-db-standby"
    }
  )
}


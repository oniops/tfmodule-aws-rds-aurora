# RDS Cluster
resource "aws_rds_cluster" "this" {
  cluster_identifier = var.cluster_name
  # cluster_identifier_prefix     = ""
  # replication_source_identifier = var.replication_source_identifier > ARN of the source DB cluster or DB instance if this DB cluster is created as a Read Replica
  # source_region                 = var.source_region > The source region for an encrypted replica DB cluster.

  engine                              = var.engine
  engine_mode                         = var.engine_mode
  engine_version                      = var.engine_version
  allow_major_version_upgrade         = var.allow_major_version_upgrade
  enable_http_endpoint                = var.enable_http_endpoint
  kms_key_id                          = var.kms_key_id
  database_name                       = var.database_name
  master_username                     = var.master_username
  master_password                     = var.master_password
  final_snapshot_identifier           = null # DB 클러스터가 삭제될 때의 최종 DB 스냅샷의 이름 으로, 생략하면 최종 스냅샷이 생성되지 않습니다.
  skip_final_snapshot                 = true # DB 클러스터를 삭제하기 전에 최종 DB 스냅샷을 생성할지 여부를 결정합니다.
  deletion_protection                 = true # var.deletion_protection
  backup_retention_period             = var.backup_retention_period
  preferred_backup_window             = var.preferred_backup_window
  preferred_maintenance_window        = var.preferred_maintenance_window
  port                                = var.port
  db_subnet_group_name                = var.db_subnet_group_name
  vpc_security_group_ids              = compact(var.rds_security_group_ids)
  snapshot_identifier                 = null
  storage_encrypted                   = var.storage_encrypted
  apply_immediately                   = var.apply_immediately
  db_cluster_parameter_group_name     = var.db_cluster_parameter_group_name
  db_instance_parameter_group_name    = null
  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  backtrack_window                    = var.backtrack_window
  copy_tags_to_snapshot               = var.copy_tags_to_snapshot
  enabled_cloudwatch_logs_exports     = var.enabled_cloudwatch_logs_exports

  tags = merge(var.context.tags,
    {
      Name    = var.cluster_name
      Cluster = var.cluster_name
    }
  )
}


# RDS Instance
resource "aws_rds_cluster_instance" "this" {
  for_each = var.instances

  # Notes:
  # Do not set preferred_backup_window - its set at the cluster level and will error if provided here

  # identifier                            = var.instances_use_identifier_prefix ? null : lookup(each.value, "identifier", "${var.name}-${each.key}")
  # identifier_prefix                     = var.instances_use_identifier_prefix ? lookup(each.value, "identifier_prefix", "${var.cluster_name}-") : null
  # identifier_prefix                     = "${var.cluster_name}-"
  identifier                            = "${var.cluster_name}-${each.key}"
  cluster_identifier                    = try(aws_rds_cluster.this.id, "")
  engine                                = var.engine
  engine_version                        = var.engine_version
  instance_class                        = lookup(each.value, "instance_class", var.instance_class)
  publicly_accessible                   = lookup(each.value, "publicly_accessible", var.publicly_accessible)
  db_subnet_group_name                  = var.db_subnet_group_name
  db_parameter_group_name               = lookup(each.value, "db_parameter_group_name", var.db_parameter_group_name)
  apply_immediately                     = lookup(each.value, "apply_immediately", var.apply_immediately)
  monitoring_role_arn                   = var.monitoring_role_arn
  monitoring_interval                   = lookup(each.value, "monitoring_interval", var.monitoring_interval)
  promotion_tier                        = lookup(each.value, "promotion_tier", var.promotion_tier)
  availability_zone                     = lookup(each.value, "availability_zone", null)
  preferred_maintenance_window          = lookup(each.value, "preferred_maintenance_window", var.preferred_maintenance_window)
  auto_minor_version_upgrade            = lookup(each.value, "auto_minor_version_upgrade", var.auto_minor_version_upgrade)
  performance_insights_enabled          = lookup(each.value, "performance_insights_enabled", var.performance_insights_enabled)
  performance_insights_kms_key_id       = lookup(each.value, "performance_insights_kms_key_id", var.performance_insights_kms_key_id)
  performance_insights_retention_period = lookup(each.value, "performance_insights_retention_period", var.performance_insights_retention_period)
  copy_tags_to_snapshot                 = lookup(each.value, "copy_tags_to_snapshot", var.copy_tags_to_snapshot)
  ca_cert_identifier                    = var.ca_cert_identifier

  timeouts {
    create = lookup(var.instance_timeouts, "create", null)
    update = lookup(var.instance_timeouts, "update", null)
    delete = lookup(var.instance_timeouts, "delete", null)
  }

  # TODO - not sure why this is failing and throwing type mis-match errors
  # tags = merge(var.tags, lookup(each.value, "tags", {}))
  tags = merge(var.context.tags,
    {
      Name    = "${var.cluster_name}-${each.key}"
      Cluster = var.cluster_name
    }
  )
}

/*
*/

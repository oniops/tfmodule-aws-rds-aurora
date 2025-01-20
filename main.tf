locals {
  create                    = var.create
  serverless                = var.engine_mode == "serverless"
  ignore_credentials        = var.replication_source_identifier != "" || var.snapshot_identifier != null
  create_cluster_parameters = local.create && var.create_parameter_group && var.cluster_parameters != null
  create_db_parameters      = local.create && var.create_parameter_group && var.db_parameters      != null
  db_parameter_group_family = var.db_parameter_group_family != null ? var.db_parameter_group_family : var.parameter_group_family
}

# RDS Cluster
resource "aws_rds_cluster" "this" {
  count                               = local.create ? 1 : 0
  cluster_identifier                  = var.cluster_name
  global_cluster_identifier           = null # The global cluster identifier specified on aws_rds_global_cluster
  # cluster_identifier_prefix     = ""
  # replication_source_identifier = var.replication_source_identifier > ARN of the source DB cluster or DB instance if this DB cluster is created as a Read Replica
  # source_region                 = var.source_region > The source region for an encrypted replica DB cluster.
  #
  engine                                = var.engine
  engine_mode                           = var.engine_mode
  engine_version                        = var.engine_version
  allow_major_version_upgrade           = var.allow_major_version_upgrade
  enable_http_endpoint                  = var.enable_http_endpoint
  kms_key_id                            = var.kms_key_id
  database_name                         = var.database_name
  master_username                       = local.ignore_credentials ? null : var.master_username
  master_password                       = local.ignore_credentials ? null : var.master_password
  db_cluster_instance_class             = var.engine == "aurora-mysql" ? "" : var.db_cluster_instance_class
  final_snapshot_identifier             = null # DB 클러스터가 삭제될 때의 최종 DB 스냅샷의 이름 으로, 생략하면 최종 스냅샷이 생성되지 않습니다.
  skip_final_snapshot                   = true # DB 클러스터를 삭제하기 전에 최종 DB 스냅샷을 생성할지 여부를 결정합니다.
  deletion_protection                   = var.deletion_protection
  backup_retention_period               = var.backup_retention_period
  preferred_backup_window               = local.serverless ? null : var.preferred_backup_window
  preferred_maintenance_window          = var.preferred_maintenance_window
  port                                  = var.port
  availability_zones                    = var.availability_zones
  db_subnet_group_name                  = var.db_subnet_group_name
  vpc_security_group_ids                = compact(var.rds_security_group_ids)
  # iops                                = var.iops
  # storage_type                        = var.storage_type
  replication_source_identifier         = var.replication_source_identifier
  snapshot_identifier                   = var.snapshot_identifier
  storage_encrypted                     = var.storage_encrypted
  apply_immediately                     = var.apply_immediately
  db_cluster_parameter_group_name       = local.create_cluster_parameters ? try(aws_rds_cluster_parameter_group.this[0].name, var.db_cluster_parameter_group_name) : var.db_cluster_parameter_group_name
  db_instance_parameter_group_name      = local.create_db_parameters ? try(aws_db_parameter_group.this[0].name, var.db_instance_parameter_group_name) : var.db_instance_parameter_group_name
  iam_database_authentication_enabled   = var.iam_database_authentication_enabled
  backtrack_window                      = var.backtrack_window
  copy_tags_to_snapshot                 = var.copy_tags_to_snapshot
  enabled_cloudwatch_logs_exports       = var.enabled_cloudwatch_logs_exports
  enable_local_write_forwarding         = var.enable_local_write_forwarding
  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_kms_key_id       = var.performance_insights_kms_key_id
  performance_insights_retention_period = var.performance_insights_retention_period

  lifecycle {
    ignore_changes = [
      # See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster#replication_source_identifier
      # Since this is used either in read-replica clusters or global clusters, this should be acceptable to specify
      replication_source_identifier,
      # See docs here https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_global_cluster#new-global-cluster-from-existing-db-cluster
      global_cluster_identifier,
      snapshot_identifier,
      availability_zones
    ]
  }

  tags = merge(
    var.context.tags,
    var.cluster_tags,
    {
      Name    = var.cluster_name
      Cluster = var.cluster_name
    }
  )

  depends_on = [
    aws_rds_cluster_parameter_group.this,
    aws_cloudwatch_log_group.this,
  ]

}

# RDS Instance
resource "aws_rds_cluster_instance" "this" {
  for_each = { for k, v in var.instances : k => v if local.create && !local.serverless }

  # Notes:
  # Do not set preferred_backup_window - its set at the cluster level and will error if provided here
  # identifier_prefix                     = var.instances_use_identifier_prefix ? lookup(each.value, "identifier_prefix", "${var.cluster_name}-") : null
  # identifier_prefix                     = "${var.cluster_name}-"
  identifier                            = format("%s-%s", var.cluster_name, coalesce(lookup(each.value, "instance_name", each.key), each.key))
  cluster_identifier                    = try(aws_rds_cluster.this[0].id, "")
  engine                                = var.engine
  engine_version                        = var.engine_version
  instance_class                        = lookup(each.value, "instance_class", var.instance_class)
  publicly_accessible                   = lookup(each.value, "publicly_accessible", var.publicly_accessible)
  db_subnet_group_name                  = var.db_subnet_group_name
  db_parameter_group_name               = local.create_db_parameters ? try(aws_db_parameter_group.this[0].name, var.db_parameter_group_name) : lookup(each.value, "db_parameter_group_name", var.db_parameter_group_name)
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
  tags = merge(
    var.context.tags,
    var.instance_tags,
    {
      Name    = format("%s-%s", var.cluster_name, coalesce(lookup(each.value, "instance_name", each.key), each.key))
      Cluster = var.cluster_name
    }
  )

  depends_on = [
    aws_db_parameter_group.this,
    aws_cloudwatch_log_group.this,
  ]
}

resource "aws_rds_cluster_role_association" "this" {
  for_each = { for k, v in var.iam_roles : k => v if local.create }

  db_cluster_identifier = try(aws_rds_cluster.this[0].id, "")
  feature_name          = lookup(each.value, "feature_name", "")
  role_arn              = lookup(each.value, "role_arn", null)

  lifecycle {
    create_before_destroy = true
    ignore_changes = []
  }

  depends_on = [
    aws_rds_cluster.this
  ]
}

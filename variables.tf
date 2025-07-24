variable "create" {
  description = "Whether cluster should be created"
  type        = bool
  default     = true
}

variable "cluster_name" {
  description = "The name for RDS cluster"
  type        = string
}

variable "engine" {
  description = "The name of the database engine to be used for this DB cluster. Defaults to `aurora`. Valid Values: `aurora`, `aurora-mysql`, `aurora-postgresql`"
  type        = string
  default     = "aurora-mysql"
}

variable "engine_mode" {
  description = "The database engine mode. Valid values: `global`, `multimaster`, `parallelquery`, `provisioned`, `serverless`. Defaults to: `provisioned`"
  type        = string
  default     = "provisioned"
}

variable "engine_version" {
  description = "The database engine version. Updating this argument results in an outage"
  type        = string
  default     = null
}

variable "allow_major_version_upgrade" {
  description = "Enable to allow major engine version upgrades when changing engine versions. Defaults to `false`"
  type        = bool
  default     = false
}

variable "enable_http_endpoint" {
  description = "Enable HTTP endpoint (data API). Only valid when engine_mode is set to `serverless`"
  type        = bool
  default     = null
}

variable "kms_key_id" {
  description = "The ARN for the KMS encryption key. When specifying `kms_key_id`, `storage_encrypted` needs to be set to `true`"
  type        = string
  default     = null
}

variable "database_name" {
  description = "Name for an automatically created database on cluster creation"
  type        = string
  default     = null
}

variable "port" {
  description = "The port on which the DB accepts connections"
  type        = string
  default     = "3306"
}

variable "master_username" {
  description = "Username for the master DB user"
  type        = string
}

variable "master_password" {
  description = "Password for the master DB user. Note - when specifying a value here, 'create_random_password' should be set to `false`"
  type        = string
}

variable "db_cluster_instance_class" {
  description = <<EOF
The compute and memory capacity of each DB instance in the Multi-AZ DB cluster, for example db.m6g.xlarge.
Not all DB instance classes are available in all AWS Regions, or for all database engines.
It is not supported for DB engine aurora-mysql.
EOF
  type        = string
  default     = ""
}

variable "deletion_protection" {
  description = "If the DB instance should have deletion protection enabled. The database can't be deleted when this value is set to true. "
  type        = bool
  default     = true
}

variable "backup_retention_period" {
  description = "The days to retain backups for. Default `7`"
  type        = number
  default     = 7
}

variable "preferred_backup_window" {
  description = "The daily time range during which automated backups are created if automated backups are enabled using the `backup_retention_period` parameter. Time in UTC"
  type        = string
  default     = "02:00-03:00"
}

variable "preferred_maintenance_window" {
  description = "The weekly time range during which system maintenance can occur, in (UTC)"
  type        = string
  default     = "sun:05:00-sun:06:00"
}

variable "availability_zones" {
  description = <<EOF
List of EC2 Availability Zones for the DB cluster storage where DB cluster instances can be created.
RDS automatically assigns 3 AZs if less than 3 AZs are configured,
which will show as a difference requiring resource recreation next Terraform apply"

Important] The "db_subnet_group_name" attribute means AZ, so if you specified a value for "db_subnet_group_name", do not set this value.
EOF
  type = list(string)
  default     = null
}

variable "db_subnet_group_name" {
  description = "The name of the database subnet group name"
  type        = string
}

variable "rds_security_group_ids" {
  description = "The name of the security grouip id for RDS Cluster"
  type = list(string)
}

variable "iops" {
  description = "The amount of Provisioned IOPS (input/output operations per second) to be initially allocated for each DB instance in the Multi-AZ DB cluster"
  type        = number
  default     = 0
}

variable "replication_source_identifier" {
  description = "ARN of a source DB cluster or DB instance if this DB cluster is to be created as a Read Replica"
  type        = string
  default     = ""
}

variable "snapshot_identifier" {
  description = "Specifies whether or not to create this cluster from a snapshot. You can use either the name or ARN when specifying a DB cluster snapshot, or the ARN when specifying a DB snapshot."
  type        = string
  default     = null
}

variable "storage_type" {
  description = <<EOF
Specifies the storage type to be associated with the DB cluster.
This setting is required to create a Multi-AZ DB cluster. Valid values: io1
EOF
  type        = string
  default     = ""
}

variable "storage_encrypted" {
  description = "Specifies whether the DB cluster is encrypted. The default is `true`"
  type        = bool
  default     = true
}

variable "apply_immediately" {
  description = "Specifies whether any cluster modifications are applied immediately, or during the next maintenance window. Default is `false`"
  type        = bool
  default     = false
}

variable "db_cluster_parameter_group_name" {
  description = "A cluster parameter group to associate with the cluster"
  type        = string
  default     = null
}

variable "db_instance_parameter_group_name" {
  description = "A parameter group to associate with the database instances"
  type        = string
  default     = null
}

variable "iam_database_authentication_enabled" {
  description = "Specifies whether or mappings of AWS Identity and Access Management (IAM) accounts to database accounts is enabled"
  type        = bool
  default     = false
}

variable "backtrack_window" {
  description = "The target backtrack window, in seconds. Only available for `aurora` engine currently. To disable backtracking, set this value to 0. Must be between 0 and 259200 (72 hours)"
  type        = number
  default     = 0
}

variable "copy_tags_to_snapshot" {
  description = "Copy all Cluster `tags` to snapshots"
  type        = bool
  default     = null
}

# see - https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-mysql-write-forwarding.html
variable "enable_local_write_forwarding" {
  description = "Whether read replicas can forward write operations to the writer DB instance in the DB cluster. By default, write operations aren't allowed on reader DB instances."
  type        = bool
  default     = null
}

# see - https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-global-database-write-forwarding.html
variable "enable_global_write_forwarding" {
  description = "Whether cluster should forward writes to an associated global cluster. Applied to secondary clusters to enable them to forward writes to an aws_rds_global_cluster's primary cluster."
  type        = bool
  default     = null
}

# aws_rds_cluster_instances
variable "instances" {
  type        = any
  default = {}
  description = <<EOF
Map of cluster instances and any specific/overriding attributes to be created

  instances = {
    writer = {
      promotion_tier      = 1
      instance_class      = var.instance_class
      instance_name       = "write01"                   # in case of name of instance
      instance_identifier = "my-aurora-cluster-write01" # in case of fullname of instance
    }
    reader = {
      promotion_tier      = 10
      instance_class      = var.instance_class
                                                        # in case of no define instance_name, use key for instance name
    }
  }
EOF
}

variable "instances_use_identifier_prefix" {
  description = "Determines whether cluster instance identifiers are used as prefixes"
  type        = bool
  default     = false
}

variable "instance_class" {
  description = "Instance type to use at master instance. Note: if `autoscaling_enabled` is `true`, this will be the same instance class used on instances created by autoscaling"
  type        = string
}

variable "publicly_accessible" {
  description = "Determines whether instances are publicly accessible. Default false"
  type        = bool
  default     = false
}

variable "db_parameter_group_name" {
  description = "The name of the DB parameter group to associate with instances."
  type        = string
  default     = null
}

variable "monitoring_role_arn" {
  description = "IAM role used by RDS to send enhanced monitoring metrics to CloudWatch"
  type        = string
  default     = null
}

variable "monitoring_interval" {
  description = "The interval, in seconds, between points when Enhanced Monitoring metrics are collected for instances. Set to `0` to disble. Default is `0`"
  type        = number
  default     = 0
}

variable "auto_minor_version_upgrade" {
  description = "Indicates that minor engine upgrades will be applied automatically to the DB instance during the maintenance window. Default `true`"
  type        = bool
  default     = false
}

variable "performance_insights_enabled" {
  description = "Specifies whether Performance Insights is enabled or not"
  type        = bool
  default     = false
}

variable "performance_insights_kms_key_id" {
  description = "The ARN for the KMS key to encrypt Performance Insights data"
  type        = string
  default     = null
}

variable "performance_insights_retention_period" {
  description = "Amount of time in days to retain Performance Insights data. Either 7 (7 days) or 731 (2 years)"
  type        = number
  default     = null
}

variable "promotion_tier" {
  description = "Failover Priority setting on instance level. The reader who has lower tier has higher priority to get promoted to writer."
  type        = number
  default     = 0
}

variable "instance_timeouts" {
  description = "Create, update, and delete timeout configurations for the cluster instance(s)"
  type = map(string)
  default = {}
}

variable "ca_cert_identifier" {
  description = "The identifier of the CA certificate for the DB instance"
  type        = string
  default     = "rds-ca-rsa2048-g1"
}

# aws_rds_cluster_role_association
variable "iam_roles" {
  description = "Map of IAM roles and supported feature names to associate with the cluster"
  type        = any
  default = {}
}

# Auto Scaling
variable "autoscaling_enabled" {
  description = "Determines whether autoscaling of the cluster read replicas is enabled"
  type        = bool
  default     = false
}


variable "autoscaling_max_capacity" {
  description = "Maximum number of read replicas permitted when autoscaling is enabled"
  type        = number
  default     = 2
}

variable "autoscaling_min_capacity" {
  description = "Minimum number of read replicas permitted when autoscaling is enabled"
  type        = number
  default     = 0
}

variable "autoscaling_policy_name" {
  description = "Autoscaling policy name"
  type        = string
  default     = "target-metric"
}

variable "predefined_metric_type" {
  description = "The metric type to scale on. Valid values are `RDSReaderAverageCPUUtilization` and `RDSReaderAverageDatabaseConnections`"
  type        = string
  default     = "RDSReaderAverageCPUUtilization"
}

variable "autoscaling_scale_in_cooldown" {
  description = "Cooldown in seconds before allowing further scaling operations after a scale in"
  type        = number
  default     = 300
}

variable "autoscaling_scale_out_cooldown" {
  description = "Cooldown in seconds before allowing further scaling operations after a scale out"
  type        = number
  default     = 300
}

variable "autoscaling_target_cpu" {
  description = "CPU threshold which will initiate autoscaling"
  type        = number
  default     = 70
}

variable "autoscaling_target_connections" {
  description = "Average number of connections threshold which will initiate autoscaling. Default value is 70% of db.r4/r5/r6g.large's default max_connections"
  type        = number
  default     = 700
}

###############################################################################
# Parameter Group for Cluster and DB Instances
###############################################################################
variable "create_parameter_group" {
  description = "Create "
  type        = bool
  default     = false
}

variable "parameter_group_family" {
  description = "The family of the DB cluster parameter group"
  type        = string
  default     = null # "aurora-mysql8.0"
}

variable "db_parameter_group_family" {
  description = "The family of the DB instance parameter group"
  type        = string
  default     = null
}

variable "cluster_parameter_group_name" {
  description = "The cluster parameter group name"
  type        = string
  default     = null
}

variable "cluster_parameter_group_description" {
  description = "The cluster parameter group name"
  type        = string
  default     = "RDS default cluster parameter group"
}

variable "instance_parameter_group_name" {
  description = "The instance parameter group name"
  type        = string
  default     = null
}

variable "cluster_parameters" {
  type        = any
  default     = null
  description = <<EOF
A collection of DB cluster parameters to apply. Note that parameters may differ from a family to an other

  cluster_parameters = {
    bulk_insert_buffer_size           = "184467440"
    join_buffer_size                  = "184467440"
    transaction_isolation             = "READ-COMMITTED"
    innodb_flush_log_at_trx_commit = {
      apply_method = "pending-reboot"
      value        = "1"
    }
  }
EOF
}

variable "db_parameters" {
  type        = any
  default     = null
  description = <<EOF
A collection of DB parameters to apply. Note that parameters may differ from a family to an other

  db_parameters = {
    autocommit                      = "0"
    bulk_insert_buffer_size         = "284467440"
    innodb_lock_wait_timeout        = "120"
    slow_query_log                  = "1"
    long_query_time                 = "100"
  }
EOF
}

variable "cluster_tags" {
  type = map(string)
  default = {}
}

variable "instance_tags" {
  type = map(string)
  default = {}
}

################################################################################
# CloudWatch Log Group
################################################################################

variable "create_cloudwatch_log_group" {
  description = "Determines whether a CloudWatch log group is created for each `enabled_cloudwatch_logs_exports`"
  type        = bool
  default     = false
}

variable "enabled_cloudwatch_logs_exports" {
  description = "Set of log types to export to cloudwatch. If omitted, no logs will be exported. The following log types are supported: `audit`, `error`, `general`, `slowquery`, `postgresql`"
  type = list(string)
  default = ["audit", "error"]
}

variable "retention_in_days" {
  description = "The number of days to retain CloudWatch logs for the DB instance"
  type        = number
  default     = 7
}

variable "cloudwatch_logs_retention_in_days" {
  type        = map(number)
  default     = {}
  description = <<EOF
The number of days to retain CloudWatch logs exports for the DB instance

  cloudwatch_logs_retention_in_days = {
    audit       = 365
    error       = 14
    general     = 14
    slowquery   = 14
    postgresql  = 7
  }
EOF

}
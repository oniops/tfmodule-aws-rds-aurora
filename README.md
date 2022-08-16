# tfmodule-aws-rds-aurora

AWS RDS Aurora 서비스를 생성 하는 테라폼 모듈 입니다.

## Usage

```
module "ctx" {
  source = "git::https://code.bespinglobal.com/scm/op/tfmodule-context.git"
  context = {  
    # ... You need to define context variables ...
  }
}

module "vpc" {
  source = "git::https://code.bespinglobal.com/scm/op/tfmodule-aws-vpc.git"
  context  = module.ctx.context
  # ... You need to define resources for vpc ...
}


locals {
  cluster_name = "${module.ctx.name_prefix}-asset-rds"
}

module "rds_asset" {
  source                          = "git::https://code.bespinglobal.com/scm/op/tfmodule-aws-rds-aurora.git"
  context                         = module.ctx.context
  cluster_name                    = local.cluster_name
  engine_version                  = "8.0.mysql_aurora.3.02.0"
  master_username                 = "root"
  master_password                 = "root1234"
  db_subnet_group_name            = "<your_db_subnet_group_name>"
  rds_security_group_ids          = ["<your_security_group_id>"]
  instance_class                  = "db.r6g.large"

  instances = {
    writer = {
      promotion_tier          = 1
    }
  }

}

```

## Inputs

<table>
<thead>
    <tr>
        <th>Name</th>
        <th>Description</th>
        <th>Type</th>
        <th>Default</th>
        <th>Required</th>
    </tr>
</thead>
<tbody>
    <tr>
        <td>context</td>
        <td>Provides standardized naming policy and attribute information for data source reference to define cloud resources for a Project.</td>
        <td>object</td>
        <td>{}</td>
        <td>yes</td>
    </tr> 
    <tr>
        <td>name</td>
        <td>RDS Cluster alias name</td>
        <td>string</td>
        <td></td>
        <td>yes</td>
    </tr> 
    <tr>
        <td>engine</td>
        <td>The database engine mode. Valid values: `global`, `multimaster`, `parallelquery`, `provisioned`, `serverless`. Defaults to: `provisioned`</td>
        <td>string</td>
        <td>aurora-mysql</td>
        <td>no</td>
    </tr> 
    <tr>
        <td>engine_mode</td>
        <td>The database engine mode. Valid values: `global`, `multimaster`, `parallelquery`, `provisioned`, `serverless`. Defaults to: `provisioned`</td>
        <td>string</td>
        <td>provisioned</td>
        <td>no</td>
    </tr>
    <tr>
        <td>engine_version</td>
        <td>The database engine version. Updating this argument results in an outage</td>
        <td>string</td>
        <td></td>
        <td>no</td>
    </tr>
    <tr>
        <td>kms_key_id</td>
        <td>The ARN for the KMS encryption key. When specifying `kms_key_id`, `storage_encrypted` needs to be set to `true`</td>
        <td>string</td>
        <td></td>
        <td>no</td>
    </tr>
    <tr>
        <td>database_name</td>
        <td>Name for an automatically created database on cluster creation</td>
        <td>string</td>
        <td>null</td>
        <td>no</td>
    </tr>
    <tr>
        <td>port</td>
        <td>The port on which the DB accepts connections</td>
        <td>string</td>
        <td>3306</td>
        <td>no</td>
    </tr>
    <tr>
        <td>master_username</td>
        <td>Username for the master DB user</td>
        <td>string</td>
        <td></td>
        <td>yes</td>
    </tr>
    <tr>
        <td>master_password</td>
        <td>Password for the master DB user.</td>
        <td>string</td>
        <td></td>
        <td>yes</td>
    </tr>
    <tr>
        <td>backup_retention_period</td>
        <td>The days to retain backups for. Default `7`</td>
        <td>number</td>
        <td>7</td>
        <td>no</td>
    </tr>
    <tr>
        <td>preferred_backup_window</td>
        <td>The daily time range during which automated backups are created if automated backups are enabled using the `backup_retention_period` parameter. Time in UTC</td>
        <td>string</td>
        <td>02:00-03:00</td>
        <td>no</td>
    </tr>
    <tr>
        <td>preferred_maintenance_window</td>
        <td>The weekly time range during which system maintenance can occur, in (UTC)</td>
        <td>string</td>
        <td>sun:05:00-sun:06:00</td>
        <td>no</td>
    </tr>
    <tr>
        <td>db_subnet_group_name</td>
        <td>The name of the database subnet group name</td>
        <td>string</td>
        <td></td>
        <td>yes</td>
    </tr>
    <tr>
        <td>rds_security_group_ids</td>
        <td>The names of the security group id for RDS Cluster</td>
        <td>list(string)</td>
        <td></td>
        <td>yes</td>
    </tr>
    <tr>
        <td>storage_encrypted</td>
        <td>Specifies whether the DB cluster is encrypted. The default is `true`</td>
        <td>bool</td>
        <td>true</td>
        <td>no</td>
    </tr>
    <tr>
        <td>apply_immediately</td>
        <td>Specifies whether any cluster modifications are applied immediately, or during the next maintenance window. Default is `false`</td>
        <td>bool</td>
        <td>false</td>
        <td>no</td>
    </tr>
    <tr>
        <td>db_cluster_parameter_group_name</td>
        <td>A cluster parameter group to associate with the cluster</td>
        <td>string</td>
        <td>null</td>
        <td>no</td>
    </tr>
    <tr>
        <td>iam_database_authentication_enabled</td>
        <td>Specifies whether or mappings of AWS Identity and Access Management (IAM) accounts to database accounts is enabled</td>
        <td>bool</td>
        <td>null</td>
        <td>no</td>
    </tr>
    <tr>
        <td>copy_tags_to_snapshot</td>
        <td>Copy all Cluster `tags` to snapshots</td>
        <td>bool</td>
        <td>null</td>
        <td>no</td>
    </tr>
    <tr>
        <td>enabled_cloudwatch_logs_exports</td>
        <td>Set of log types to export to cloudwatch. If omitted, no logs will be exported. The following log types are supported: `audit`, `error`, `general`, `slowquery`, `postgresql`</td>
        <td>list(string)</td>
        <td>["audit", "error"]</td>
        <td>no</td>
    </tr>
    <tr>
        <td>instances</td>
        <td>Map of cluster instances and any specific/overriding attributes to be created</td>
        <td>Map</td>
        <td>{}</td>
        <td>no</td>
    </tr>
    <tr>
        <td>instance_class</td>
        <td>Instance type to use at master instance.</td>
        <td>string</td>
        <td></td>
        <td>yes</td>
    </tr>
    <tr>
        <td>publicly_accessible</td>
        <td>Determines whether instances are publicly accessible. Default false.</td>
        <td>bool</td>
        <td>false</td>
        <td>no</td>
    </tr>
    <tr>
        <td>db_parameter_group_name</td>
        <td>The name of the DB parameter group to associate with instances.</td>
        <td>string</td>
        <td>null</td>
        <td>no</td>
    </tr>
    <tr>
        <td>monitoring_role_arn</td>
        <td>IAM role used by RDS to send enhanced monitoring metrics to CloudWatch</td>
        <td>string</td>
        <td>null</td>
        <td>no</td>
    </tr>
    <tr>
        <td>monitoring_interval</td>
        <td>The interval, in seconds, between points when Enhanced Monitoring metrics are collected for instances. Set to `0` to disble. Default is `0`</td>
        <td>number</td>
        <td>0</td>
        <td>no</td>
    </tr>
    <tr>
        <td>auto_minor_version_upgrade</td>
        <td>Indicates that minor engine upgrades will be applied automatically to the DB instance during the maintenance window. Default `false`</td>
        <td>bool</td>
        <td>false</td>
        <td>no</td>
    </tr>
    <tr>
        <td>performance_insights_enabled</td>
        <td>Specifies whether Performance Insights is enabled or not</td>
        <td>bool</td>
        <td>false</td>
        <td>no</td>
    </tr>
    <tr>
        <td>performance_insights_kms_key_id</td>
        <td>The ARN for the KMS key to encrypt Performance Insights data</td>
        <td>string</td>
        <td>null</td>
        <td>no</td>
    </tr>
    <tr>
        <td>performance_insights_retention_period</td>
        <td>Amount of time in days to retain Performance Insights data. Either 7 (7 days) or 731 (2 years)</td>
        <td>number</td>
        <td>null</td>
        <td>no</td>
    </tr>
    <tr>
        <td>promotion_tier</td>
        <td>Failover Priority setting on instance level. The reader who has lower tier has higher priority to get promoted to writer.</td>
        <td>number</td>
        <td>0</td>
        <td>no</td>
    </tr>
    <tr>
        <td>ca_cert_identifier</td>
        <td>The identifier of the CA certificate for the DB instance</td>
        <td>string</td>
        <td>null</td>
        <td>no</td>
    </tr>
</tbody>
</table>

## Outputs

| Name | Description              |
|------|--------------------------|
| rds_cluster_name  |  The name of RDS Cluster |
| rds_cluster_endpoint  |  RDS cluster endpoint    |
| rds_cluster_reader_endpoint  |  RDS reader endpoint     |
| rds_cluster_security_group_ids  |  RDS security groups     |
| rds_database_name  | RDS database name        |
| rds_database_port  | RDS lister port          |
| rds_database_master_username  |  RDS master username     |

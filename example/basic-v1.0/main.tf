locals {
  module_name = "portal"
  rds_name    = "${module.ctx.name_prefix}-${local.module_name}-rds"
  project     = module.ctx.project
  name_prefix = module.ctx.name_prefix
}

module "ctx" {
  source  = "git::https://code.bespinglobal.com/scm/op/tfmodule-context.git"
  context = {
    project     = "otcmp"
    region      = "ap-northeast-1"
    environment = "Testbed"
    department  = "OpsNow"
    team        = "DevIos"
    cost_center = 111111
    owner       = "yoonsoo.chang@bespinglobal.com"
    customer    = "OpsNow Test Company"
    domain      = "opsnowtest.co.uk"
    pri_domain  = "backend.opsnow.com"
  }
}


resource "aws_security_group" "this" {
  name        = "${local.rds_name}-sg"
  description = "${local.rds_name}-sg"
}

module "rds" {
  source                          = "git::https://code.bespinglobal.com/scm/op/tfmodule-aws-rds-aurora.git?ref=v1.0.0"
  context                         = module.ctx.context
  cluster_name                    = local.rds_name
  engine_version                  = "5.7.mysql_aurora.2.10.1"
  master_username                 = "admin"
  master_password                 = "Admin123$"
  preferred_backup_window         = "16:23-16:53"
  preferred_maintenance_window    = "sat:04:00-sat:04:30"
  db_subnet_group_name            = data.aws_db_subnet_group.rds.name
  rds_security_group_ids          = [aws_security_group.this.id]
  enabled_cloudwatch_logs_exports = ["audit", "error"]
  db_cluster_parameter_group_name = null # aws_rds_cluster_parameter_group.this.name
  copy_tags_to_snapshot           = true
  instance_class                  = "db.t4g.medium"

  instances = {
    writer = {
      promotion_tier          = 1
    }
  }

}

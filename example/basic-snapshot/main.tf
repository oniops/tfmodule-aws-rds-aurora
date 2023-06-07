locals {
  module_name = "portal"
  rds_name    = "${module.ctx.name_prefix}-${local.module_name}-rds"
  project     = module.ctx.project
  name_prefix = module.ctx.name_prefix
}

module "ctx" {
  source  = "git::https://code.bespinglobal.com/scm/op/tfmodule-context.git"
  context = {
    project     = "mea"
    region      = "me-central-1"
    environment = "Production"
    department  = "OpsNow"
    owner       = "mark.reyes.bespinglobal@gmail.com"
    customer    = "BGMEA"
    team        = "DevOps"
    domain      = "opsnow.me"
    pri_domain  = "backend.opsnow.com"
    # pri_domain  = "backend.opsnow.local"
  }

}

resource "aws_security_group" "this" {
  name        = "${local.rds_name}-sg"
  description = "Security Group for ${local.rds_name}"
  vpc_id      = data.aws_vpc.this.id

  ingress {
    description     = "MySQL for VPC"
    cidr_blocks     = [ data.aws_vpc.this.cidr_block ]
    protocol        = "tcp"
    from_port       = 3306
    to_port         = 3306
  }

  tags = merge(module.ctx.tags, { Name = "${local.rds_name}-sg" })
}

module "rds" {
  source                          = "../../"
  ## source                          = "git::https://code.bespinglobal.com/scm/op/tfmodule-aws-rds-aurora.git"
  context                         = module.ctx.context
  cluster_name                    = local.rds_name
  engine_version                  = "8.0.mysql_aurora.3.03.1"
  snapshot_identifier             = "portal-test-rds-2023-06-07"
  master_username                 = ""
  master_password                 = ""
  preferred_backup_window         = "16:23-16:53"
  preferred_maintenance_window    = "sat:04:00-sat:04:30"
  db_subnet_group_name            = data.aws_db_subnet_group.rds.name
  rds_security_group_ids          = [aws_security_group.this.id]
  enabled_cloudwatch_logs_exports = ["audit", "error"]
  db_cluster_parameter_group_name = null # aws_rds_cluster_parameter_group.this.name
  copy_tags_to_snapshot           = true
  instance_class                  = "db.t3.medium" # "db.r5.large"

  instances = {
    writer = {
      promotion_tier          = 1
    }
  }

}

data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = ["${module.ctx.name_prefix}-vpc"]
  }
}

data "aws_db_subnet_group" "rds" {
  name = "${local.name_prefix}-data-sng"
}

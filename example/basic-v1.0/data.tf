data "aws_db_subnet_group" "rds" {
  name = "${local.name_prefix}-data-sng"
}

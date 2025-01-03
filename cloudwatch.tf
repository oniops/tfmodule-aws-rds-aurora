# Log groups will not be created if using a cluster identifier prefix
resource "aws_cloudwatch_log_group" "this" {
  for_each = toset([for log in var.enabled_cloudwatch_logs_exports : log if local.create && var.create_cloudwatch_log_group])

  name              = "/aws/rds/cluster/${var.cluster_name}/${each.value}"
  retention_in_days = lookup(var.cloudwatch_logs_retention_in_days, each.value, var.retention_in_days)
  kms_key_id        = null
  skip_destroy      = null
  log_group_class   = null

  tags = var.context.tags
}
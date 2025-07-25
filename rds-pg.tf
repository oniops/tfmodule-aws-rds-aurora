locals {
  cluster_parameter_name    = var.cluster_parameter_group_name == null ? "${var.cluster_name}-pg" : var.cluster_parameter_group_name
  instance_parameter_name   = var.instance_parameter_group_name == null ? "${var.cluster_name}-instance-pg" : var.instance_parameter_group_name
}

resource "aws_rds_cluster_parameter_group" "this" {
  count       = local.create_cluster_parameters ? 1 : 0
  name        = local.cluster_parameter_name
  family      = var.parameter_group_family
  description = var.cluster_parameter_group_description
  dynamic "parameter" {
    for_each = keys(var.cluster_parameters)
    content {
      name         = parameter.value
      value        = try(lookup(var.cluster_parameters[parameter.value], "value"), lookup(var.cluster_parameters, parameter.value))
      apply_method = try(lookup(var.cluster_parameters[parameter.value], "apply_method", "immediate"), "immediate")
    }
  }

  tags = merge(var.context.tags, {
    Name = local.cluster_parameter_name
  })

}

resource "aws_db_parameter_group" "this" {
  count       = local.create_db_parameters ? 1 : 0
  name        = local.instance_parameter_name
  family      = local.db_parameter_group_family
  description = var.instance_parameter_group_description # "RDS default instance parameter group"

  dynamic "parameter" {
    for_each = keys(var.db_parameters)
    content {
      name         = parameter.value
      value        = try(lookup(var.db_parameters[parameter.value], "value"), lookup(var.db_parameters, parameter.value))
      apply_method = try(lookup(var.db_parameters[parameter.value], "apply_method", "immediate"), "immediate")
    }
  }

  tags = merge(var.context.tags, {
    Name = local.instance_parameter_name
  })

}

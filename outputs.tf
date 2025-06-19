output "rds_cluster_name" {
  value = try(aws_rds_cluster.this[0].cluster_identifier, "")
}

output "cluster_name" {
  value = try(aws_rds_cluster.this[0].cluster_identifier, "")
}

output "instance_identifiers" {
  value =  try([for instance in aws_rds_cluster_instance.this : instance.identifier], [])
}

output "engine" {
  value = try(aws_rds_cluster.this[0].engine, "")
}

output "cluster_endpoint" {
  value = try(aws_rds_cluster.this[0].endpoint, "")
}

output "cluster_reader_endpoint" {
  value = try(aws_rds_cluster.this[0].reader_endpoint, "")
}

output "cluster_security_group_ids" {
  value = try(aws_rds_cluster.this[0].vpc_security_group_ids, "")
}

output "database_name" {
  value = try(aws_rds_cluster.this[0].database_name, "")
}

output "port" {
  value = try(aws_rds_cluster.this[0].port, "")
}

output "master_username" {
  value = try(aws_rds_cluster.this[0].master_username, "")
}

output "availability_zones" {
  value = try(aws_rds_cluster.this[0].availability_zones, "")
}

output "cluster_parameter_group" {
  value = var.create_parameter_group ? try(aws_rds_cluster_parameter_group.this[0].name, "") : ""
}

output "db_parameter_group" {
  value = var.create_parameter_group ? try(aws_db_parameter_group.this[0].name, "") : ""
}

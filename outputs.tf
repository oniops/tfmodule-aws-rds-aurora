output "rds_cluster_name" {
  value = aws_rds_cluster.this.cluster_identifier
}

output "rds_cluster_endpoint" {
  value = aws_rds_cluster.this.endpoint
}

output "rds_cluster_reader_endpoint" {
  value = aws_rds_cluster.this.reader_endpoint
}

output "rds_cluster_security_group_ids" {
  value = aws_rds_cluster.this.vpc_security_group_ids
}

output "rds_database_name" {
  value = aws_rds_cluster.this.database_name
}

output "rds_database_port" {
  value = aws_rds_cluster.this.port
}

output "rds_database_master_username" {
  value = aws_rds_cluster.this.master_username
}

output "availability_zones" {
  value = aws_rds_cluster.this.availability_zones
}

output "db_endpoint" {
  description = "Connection endpoint (host:port) for the database."
  value       = aws_db_instance.metabase.endpoint
}

output "db_address" {
  description = "Hostname of the database."
  value       = aws_db_instance.metabase.address
}

output "db_port" {
  description = "Port the database listens on."
  value       = aws_db_instance.metabase.port
}

output "db_name" {
  description = "Name of the initial database."
  value       = aws_db_instance.metabase.db_name
}

output "db_username" {
  description = "Master username."
  value       = aws_db_instance.metabase.username
}

output "db_password" {
  description = "Master password (generated). Sensitive; retrieve with `terraform output -raw db_password`."
  value       = random_password.db.result
  sensitive   = true
}

output "db_security_group_id" {
  description = "ID of the security group attached to the database."
  value       = aws_security_group.db.id
}

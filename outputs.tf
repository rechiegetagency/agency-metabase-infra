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
  description = "Master password. Only set when manage_master_user_password = false; otherwise null (fetch it from Secrets Manager instead — see db_master_user_secret_arn)."
  value       = var.manage_master_user_password ? null : random_password.db[0].result
  sensitive   = true
}

output "db_master_user_secret_arn" {
  description = "ARN of the Secrets Manager secret holding the RDS-managed master credentials. Null when manage_master_user_password = false."
  value       = var.manage_master_user_password ? aws_db_instance.metabase.master_user_secret[0].secret_arn : null
}

output "db_security_group_id" {
  description = "ID of the security group attached to the database."
  value       = aws_security_group.db.id
}

output "cloudwatch_alarm_names" {
  description = "Names of the CloudWatch alarms monitoring the database."
  value = [
    aws_cloudwatch_metric_alarm.cpu_high.alarm_name,
    aws_cloudwatch_metric_alarm.free_storage_low.alarm_name,
    aws_cloudwatch_metric_alarm.freeable_memory_low.alarm_name,
  ]
}

output "alarm_sns_topic_arn" {
  description = "SNS topic that alarm notifications are published to."
  value       = data.aws_sns_topic.alarms.arn
}

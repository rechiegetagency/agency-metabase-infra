# CloudWatch alarms for the RDS instance, notifying an existing SNS topic
# (Email_Devs) whose subscribers receive the alerts by email.

data "aws_sns_topic" "alarms" {
  name = var.alarm_sns_topic_name
}

locals {
  # Notify on ALARM transitions only (no OK notifications, to reduce noise).
  alarm_actions = [data.aws_sns_topic.alarms.arn]
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${local.name_prefix}-cpu-high"
  alarm_description   = "CPUUtilization >= ${var.cpu_utilization_threshold}% on ${aws_db_instance.metabase.identifier}"
  namespace           = "AWS/RDS"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = var.cpu_utilization_threshold
  unit                = "Percent"
  period              = 300
  evaluation_periods  = 2
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.metabase.identifier
  }

  alarm_actions = local.alarm_actions

  tags = {
    Name = "${local.name_prefix}-cpu-high"
  }
}

resource "aws_cloudwatch_metric_alarm" "free_storage_low" {
  alarm_name          = "${local.name_prefix}-free-storage-low"
  alarm_description   = "FreeStorageSpace < ${var.free_storage_space_threshold_bytes} bytes on ${aws_db_instance.metabase.identifier}"
  namespace           = "AWS/RDS"
  metric_name         = "FreeStorageSpace"
  statistic           = "Average"
  comparison_operator = "LessThanThreshold"
  threshold           = var.free_storage_space_threshold_bytes
  unit                = "Bytes"
  period              = 300
  evaluation_periods  = 1
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.metabase.identifier
  }

  alarm_actions = local.alarm_actions

  tags = {
    Name = "${local.name_prefix}-free-storage-low"
  }
}

resource "aws_cloudwatch_metric_alarm" "freeable_memory_low" {
  alarm_name          = "${local.name_prefix}-freeable-memory-low"
  alarm_description   = "FreeableMemory < ${var.freeable_memory_threshold_bytes} bytes on ${aws_db_instance.metabase.identifier}"
  namespace           = "AWS/RDS"
  metric_name         = "FreeableMemory"
  statistic           = "Average"
  comparison_operator = "LessThanThreshold"
  threshold           = var.freeable_memory_threshold_bytes
  unit                = "Bytes"
  period              = 300
  evaluation_periods  = 1
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.metabase.identifier
  }

  alarm_actions = local.alarm_actions

  tags = {
    Name = "${local.name_prefix}-freeable-memory-low"
  }
}

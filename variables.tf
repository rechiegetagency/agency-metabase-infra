variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Deployment environment name (e.g. prod, staging)."
  type        = string
  default     = "prod"
}

variable "tags" {
  description = "Additional tags applied to all resources."
  type        = map(string)
  default     = {}
}

# --- Networking (references to existing infrastructure) ---

variable "vpc_id" {
  description = "ID of the existing VPC the database will live in."
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the DB subnet group. Use private subnets in at least two AZs."
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "RDS requires at least two subnets in different availability zones."
  }
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to reach the database on the PostgreSQL port. Leave empty and use allowed_security_group_ids instead where possible."
  type        = list(string)
  default     = []
}

variable "allowed_security_group_ids" {
  description = "Security group IDs allowed to reach the database (e.g. the Metabase app/ECS/EC2 security group)."
  type        = list(string)
  default     = []
}

# --- Database engine ---

variable "engine_version" {
  description = "PostgreSQL major (or major.minor) version."
  type        = string
  default     = "16"
}

variable "instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.t4g.micro"
}

variable "allocated_storage" {
  description = "Initial storage allocation in GiB."
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Upper limit for storage autoscaling in GiB. Set equal to allocated_storage to disable autoscaling."
  type        = number
  default     = 100
}

variable "db_name" {
  description = "Name of the initial database created inside the instance (Metabase's application DB)."
  type        = string
  default     = "metabase"
}

variable "db_username" {
  description = "Master username for the database."
  type        = string
  default     = "metabase"
}

variable "db_port" {
  description = "Port the database listens on."
  type        = number
  default     = 5432
}

# --- Availability & lifecycle ---

variable "multi_az" {
  description = "Whether to deploy a standby instance in another AZ for high availability."
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "Number of days to retain automated backups."
  type        = number
  default     = 7
}

variable "deletion_protection" {
  description = "Prevent the instance from being destroyed by Terraform or the console."
  type        = bool
  default     = true
}

variable "skip_final_snapshot" {
  description = "Skip the final snapshot when the instance is destroyed. Keep false for anything you care about."
  type        = bool
  default     = false
}

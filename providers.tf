provider "aws" {
  region = var.aws_region

  default_tags {
    tags = merge(
      {
        Application = "agency-metabase"
        ManagedBy   = "terraform"
        Environment = var.environment
      },
      var.tags,
    )
  }
}

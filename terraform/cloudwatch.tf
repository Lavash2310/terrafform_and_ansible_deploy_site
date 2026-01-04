resource "aws_cloudwatch_log_group" "app_log_group" {
  name              = "logging-group"
  retention_in_days = 7
}
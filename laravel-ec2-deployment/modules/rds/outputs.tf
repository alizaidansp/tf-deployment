output "db_endpoint" {
  # value = aws_db_instance.db.endpoint
  value = split(":", aws_db_instance.db.endpoint)[0]  # Takes the part before ":"
  # value       = replace(module.rds.db_instance_endpoint, "/:%$/", "") # Remove port and %

}
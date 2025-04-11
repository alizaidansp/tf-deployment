resource "aws_db_instance" "db" {
  identifier           = "lamp-db"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  allocated_storage    = 20
  db_name              = var.db_name
  username             = var.db_username
  password             = var.db_password
  vpc_security_group_ids = [var.security_group_id]
  db_subnet_group_name = aws_db_subnet_group.db.name
  multi_az             = var.multi_az  # Enable Multi-AZ
  skip_final_snapshot  = true
  tags = {
    Name = "lamp-db"
  }
}

resource "aws_db_subnet_group" "db" {
  name       = "lamp-db-subnet-group"
  subnet_ids = var.subnet_ids
  tags = {
    Name = "lamp-db-subnet-group"
  }
}
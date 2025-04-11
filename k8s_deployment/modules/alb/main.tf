resource "aws_lb" "main" {
  name               = "laravel-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security_group_id]
  subnets            = var.subnet_ids
  tags = {
    Name = "laravel-alb"
  }
}

resource "aws_lb_target_group" "main" {
  name     = "laravel-tg"
  port     = var.target_group_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = var.target_group_port
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}
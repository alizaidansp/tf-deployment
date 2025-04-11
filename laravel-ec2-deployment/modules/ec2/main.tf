data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_launch_template" "app" {
  name_prefix   = "lamp-app-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  # key_name      = var.ssh_key_name
  iam_instance_profile {
    name = var.iam_instance_profile
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [var.security_group_id]
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    yum update -y
    amazon-linux-extras install docker -y
    service docker start
    usermod -a -G docker ec2-user

    aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin 183631301567.dkr.ecr.eu-west-1.amazonaws.com

    docker pull 183631301567.dkr.ecr.eu-west-1.amazonaws.com/lamp-app:latest || echo "Pull failed" >> /var/log/user-data.log

    docker run -d -p 80:80 \
      -e DB_HOST=${var.db_host} \
      -e DB_CONNECTION=mysql \
      -e DB_PORT=3306 \
      -e DB_DATABASE=laraveldb \
      -e DB_USERNAME=admin \
      -e DB_PASSWORD="${var.db_password}" \
      183631301567.dkr.ecr.eu-west-1.amazonaws.com/lamp-app:latest || echo "Run failed" >> /var/log/user-data.log

    sleep 10

    CONTAINER_ID=$(docker ps -q -f "ancestor=183631301567.dkr.ecr.eu-west-1.amazonaws.com/lamp-app:latest")
    if [ -n "$CONTAINER_ID" ]; then
      docker exec $CONTAINER_ID php artisan session:table || echo "Session table failed" >> /var/log/user-data.log
      docker exec $CONTAINER_ID php artisan migrate:fresh --seed || echo "Migration failed" >> /var/log/user-data.log
    else
      echo "No container running" >> /var/log/user-data.log
    fi
  EOF
  )

  tags = {
    Name = "lamp-ec2"
  }
}

resource "aws_autoscaling_group" "app" {
  desired_capacity    = 1
  max_size            = 2
  min_size            = 1
  vpc_zone_identifier = var.subnet_ids
  target_group_arns   = [var.alb_target_group_arn]
  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "lamp-ec2-asg"
    propagate_at_launch = true
  }
}

# Data source to fetch instances managed by the ASG
data "aws_instances" "asg_instances" {
  instance_tags = {
    "aws:autoscaling:groupName" = aws_autoscaling_group.app.name
  }

  depends_on = [aws_autoscaling_group.app]
}
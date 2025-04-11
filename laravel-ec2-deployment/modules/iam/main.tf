# IAM Role for EC2 instances
resource "aws_iam_role" "ec2_role" {
  name = "${var.role_name}-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
  tags = {
    Name = "${var.role_name}-role"
  }
}

# Attach ECR Read-Only Policy
resource "aws_iam_role_policy_attachment" "ec2_ecr_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Optional: Custom Policy for additional permissions (e.g., Secrets Manager)
resource "aws_iam_policy" "ec2_custom_policy" {
  name        = "${var.role_name}-custom-policy"
  description = "Custom policy for EC2 instances"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ]
        Resource = "arn:aws:ecr:${var.region}:183631301567:repository/lamp-app"
      }
      # Add more statements here if needed (e.g., Secrets Manager, S3)
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_custom_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ec2_custom_policy.arn
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "${var.role_name}-instance-profile"
  role = aws_iam_role.ec2_role.name
}


# Add SSM policy attachment(securely getting into EC2 instances)
resource "aws_iam_role_policy_attachment" "ec2_ssm_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}



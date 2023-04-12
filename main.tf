# creating security group for ALB
resource "aws_security_group" "main" {
  name        = "${var.env}-alb-${var.subnets_name}-security-group"
  description = "${var.env}-alb-${var.subnets_name}-security-group"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.allow_cidr
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    { Name = "${var.env}-alb-${var.subnets_name}-security-group" }
  )
}


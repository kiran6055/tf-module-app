# creating security group for app
resource "aws_security_group" "main" {
  name        = "${var.env}--${var.component}-security-group"
  description = "${var.env}--${var.component}-security-group"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP"
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = var.bastion_cidr
  }
  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
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
    { Name = "${var.env}-${var.component}-security-group" }
  )
}

# creating launch template for autoscaling group
resource "aws_launch_template" "main" {
  name_prefix   = "${var.env}-${var.component}"
  image_id      = data.aws_ami.centos8.id
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.main.id]
}


# creating autoscaling group
resource "aws_autoscaling_group" "asg" {
  name                      = "${var.env}-${var.component}"
  max_size                  = var.max_size
  min_size                  = var.min_size
  desired_capacity          = var.desired_capacity
  force_delete              = true

  vpc_zone_identifier       = var.subnet_ids

  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }

  dynamic "tag" {
    for_each = local.all_tags
    content {
      key       = tag.value.key
      value     = tag.value.value
      propagate_at_launch = true
    }
  }
}


#key                 = "Foo"
#value               = "Bar"
#propagate_at_launch = true



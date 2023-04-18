# creating Iam role for ansible mechanism to have ansible pull mechanism
resource "aws_iam_role" "role" {
  name = "${var.env}--${var.component}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = merge(
    local.common_tags,
    { Name = "${var.env}-${var.component}-iam-role" }
  )
}

# creating instance profile for role
resource "aws_iam_instance_profile" "profile" {
  name = "${var.env}--${var.component}-role"
  role = aws_iam_role.role.name
}

#creating  policy to the role with the help of UI creating JSon code
resource "aws_iam_policy" "policy" {
  name        = "${var.env}--${var.component}-parameter-store-policy"
  path        = "/"
  description = "${var.env}--${var.component}-parameter-store-policy"


  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "VisualEditor0",
        "Effect" : "Allow",
        "Action" : [
          "ssm:GetParameterHistory",
          "ssm:GetParametersByPath",
          "ssm:GetParameters",
          "ssm:GetParameter"
        ],
        "Resource" : [
          "arn:aws:ssm:us-east-1:742313604750:parameter/${var.env}.${var.component}*",
          "arn:aws:ssm:us-east-1:742313604750:parameter/nexus*"
        ]
      },
      {
        "Sid" : "VisualEditor1",
        "Effect" : "Allow",
        "Action" : "ssm:DescribeParameters",
        "Resource" : "*"
      }
    ]
  })
}

#attaching role with policy
resource "aws_iam_role_policy_attachment" "role-attach" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.policy.arn
}

# creating security group for app
resource "aws_security_group" "main" {
  name        = "${var.env}-${var.component}-security-group"
  description = "${var.env}-${var.component}-security-group"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP"
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = var.allow_cidr
  }
  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.bastion_cidr
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
  name          = "${var.env}-${var.component}"
  image_id      = data.aws_ami.centos8.id
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.main.id]
  user_data = base64encode(templatefile("${path.module}/user-data.sh", { component = var.component, env = var.env }))

  iam_instance_profile {
    arn = aws_iam_instance_profile.profile.arn
  }

  instance_market_options {
    market_type = "spot"
  }

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



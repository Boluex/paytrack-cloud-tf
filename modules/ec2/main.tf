data "aws_ssm_parameter" "al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

############################################
# IAM Role for SSM (no SSH keys needed)
############################################
resource "aws_iam_role" "ec2" {
  name = "${var.name_prefix}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "ec2" {
  name = "${var.name_prefix}-ec2-profile"
  role = aws_iam_role.ec2.name
}

############################################
# Launch Template
############################################
resource "aws_launch_template" "this" {
  name_prefix   = "${var.name_prefix}-lt-"
  image_id      = data.aws_ssm_parameter.al2023_ami.value
  instance_type = var.instance_type
  key_name      = var.key_name
  user_data     = base64encode(var.user_data)

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2.name
  }

  vpc_security_group_ids = [var.ec2_sg_id]

  metadata_options {
    http_tokens                 = "required" # IMDSv2 enforced
    http_put_response_hop_limit = 1
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = 20
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }

  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"
    tags          = merge(var.tags, { Name = "${var.name_prefix}-instance" })
  }

  lifecycle {
    create_before_destroy = true
  }
}

############################################
# Auto Scaling Group
############################################
resource "aws_autoscaling_group" "this" {
  name                      = "${var.name_prefix}-asg"
  vpc_zone_identifier       = var.private_subnet_ids
  min_size                  = var.min_size
  max_size                  = var.max_size
  desired_capacity          = var.desired_capacity
  health_check_type         = "EC2"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.name_prefix}-instance"
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = var.tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}

resource "aws_autoscaling_policy" "cpu_target_tracking" {
  name                   = "${var.name_prefix}-cpu-target-tracking"
  autoscaling_group_name = aws_autoscaling_group.this.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 60
  }
}

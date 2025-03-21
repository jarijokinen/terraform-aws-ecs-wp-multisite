resource "aws_launch_template" "wp" {
  image_id               = "ami-01324684792f591ee"
  instance_type          = "t4g.micro"
  update_default_version = true
  vpc_security_group_ids = [aws_security_group.ec2.id]
  user_data = base64encode(
    <<-EOT
      #!/bin/bash
      echo ECS_CLUSTER=wp >> /etc/ecs/ecs.config
    EOT
  )

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_instance.name
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      delete_on_termination = true
      volume_size           = 30
      volume_type           = "gp3"
    }
  }
}

resource "aws_autoscaling_group" "wp" {
  min_size         = 1
  max_size         = 3
  desired_capacity = 1
  force_delete     = true
  vpc_zone_identifier = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]

  launch_template {
    id      = aws_launch_template.wp.id
    version = "$Latest"
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [desired_capacity]
  }
}

resource "aws_ecs_cluster" "wp" {
  name = "wp"
}

resource "aws_ecs_capacity_provider" "wp" {
  name = "wp"

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.wp.arn

    managed_scaling {
      status                    = "ENABLED"
      target_capacity           = 50
      minimum_scaling_step_size = 1
      maximum_scaling_step_size = 5
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "wp" {
  cluster_name       = aws_ecs_cluster.wp.name
  capacity_providers = [aws_ecs_capacity_provider.wp.name]

  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.wp.name
    base              = 1
    weight            = 100
  }
}

resource "aws_ecs_task_definition" "wp" {
  family                   = "wp"
  requires_compatibilities = ["EC2"]
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn
  container_definitions    = <<-EOT
    [
      {
        "name": "wp",
        "image": "${aws_ecr_repository.wp.repository_url}:latest",
        "memory": 512,
        "portMappings": [
          {
            "containerPort": 8080,
            "hostPort": 8080
          }
        ],
        "essential": true,
        "mountPoints": [
          {
            "sourceVolume": "efs-wp",
            "containerPath": "/wp-uploads"
          }
        ],
        "secrets": [
          {
            "name": "WORDPRESS_DB_USER",
            "valueFrom": "${aws_db_instance.wp.master_user_secret.0.secret_arn}:username::"
          },
          {
            "name": "WORDPRESS_DB_PASSWORD",
            "valueFrom": "${aws_db_instance.wp.master_user_secret.0.secret_arn}:password::"
          }
        ],
        "environment": [
          {
            "name": "WORDPRESS_DOMAIN",
            "value": "${var.domain_name}"
          },
          {
            "name": "WORDPRESS_DB_HOST",
            "value": "${aws_db_instance.wp.endpoint}"
          },
          {
            "name": "WORDPRESS_DB_NAME",
            "value": "${aws_db_instance.wp.db_name}"
          }
        ]
      }
    ]
  EOT

  volume {
    name = "efs-wp"

    efs_volume_configuration {
      file_system_id = aws_efs_file_system.wp.id
    }
  }
}

resource "aws_ecs_service" "wp" {
  name                   = "wp"
  cluster                = aws_ecs_cluster.wp.id
  task_definition        = aws_ecs_task_definition.wp.arn
  desired_count          = 1
  force_new_deployment   = true
  enable_execute_command = true

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.wp.name
    weight            = 100
  }

  network_configuration {
    subnets         = [aws_subnet.private_a.id, aws_subnet.private_b.id]
    security_groups = [aws_security_group.ec2.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.wp.arn
    container_name   = "wp"
    container_port   = 8080
  }

  triggers = {
    redeployment = plantimestamp()
  }
}

resource "aws_lb" "wp" {
  name               = "wp-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.wp.id]
  subnets            = [aws_subnet.public_a.id, aws_subnet.public_b.id]
}

resource "aws_lb_target_group" "wp" {
  name_prefix = "wp-tg-"
  port        = 8080
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.wp.id

  health_check {
    path     = "/"
    port     = 8080
    protocol = "HTTP"
    matcher  = "200-399"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "wp" {
  load_balancer_arn = aws_lb.wp.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Access Denied"
      status_code  = "403"
    }
  }
}

resource "aws_lb_listener_rule" "wp" {
  listener_arn = aws_lb_listener.wp.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wp.arn
  }

  condition {
    http_header {
      http_header_name = "X-Secret-Header"
      values           = [var.lb_secret_header]
    }
  }
}

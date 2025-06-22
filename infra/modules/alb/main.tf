resource "aws_alb" "main" {
  name = "pgagi-alb"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.alb.id]
  subnets = var.public_subnets
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_alb.main.arn
  port = 80
  protocol = "HTTP"
  
  default_action {
    type = "forward"
    target_group_arn = var.frontend_target_group_arn
  }
}

resource "aws_lb_listener_rule" "api_route" {
  listener_arn = aws_lb_listener.http.arn
  priority = 100
  action {
    type = "forward"
    target_group_arn = var.backend_target_group_arn
  }
  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }
}

resource "aws_security_group" "alb" {
  name = "alb-sg"
  description = "Allow inbound rule"
  vpc_id = var.vpc_id

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


#ECS CLuster
resource "aws_ecs_cluster" "main"{
  name = var.cluster_name
}

#IAM role for EC2 Instances
resource "aws_iam_role" "ecs_instance_role" {
    name = "ecsInstanceRole"

    assume_role_policy = jsonencode({
        Version = "2012-10-17",
        Statement = [{
            Effect = "Allow",
            Principal = { Service = "ec2.amazonaws.com" },
            Action = "sts:AssumeRole"
        }]
    })
}

resource "aws_iam_role_policy_attachment" "ecs_instance_role_policy" {
  role = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

#Launch Template
data "aws_ami" "ecs" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }
}

resource "aws_iam_instance_profile" "ecs_profile" {
  name = "ecsInstanceProfile"
  role = aws_iam_role.ecs_instance_role.name
}

resource "aws_security_group" "ecs_instances" {
  name        = "ecs-instances-sg"
  description = "Allow traffic from ALB"
  vpc_id      = var.vpc_id

  ingress {
    description      = "Allow traffic from ALB"
    from_port        = var.backend_port
    to_port          = var.backend_port
    protocol         = "tcp"
    security_groups  = [var.alb_sg_id]
  }

  ingress {
    from_port        = var.frontend_port
    to_port          = var.frontend_port
    protocol         = "tcp"
    security_groups  = [var.alb_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ecs-instance-sg"
  }
}

resource "aws_launch_template" "ecs" {
  name_prefix = "ecs-launch-template"
  image_id = data.aws_ami.ecs.id
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.ecs_instances.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_profile.name
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    echo ECS_CLUSTER=${var.cluster_name} >> /etc/ecs/ecs.config
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "ecs-instance"
    }
  }

}

#Auto Scaling Group
resource "aws_autoscaling_group" "ecs_instances" {
  name = "ecs-asg"
  min_size = 4
  max_size = 4
  desired_capacity = 4
  vpc_zone_identifier = var.private_subnets
  health_check_type         = "EC2"
  health_check_grace_period = 300
  launch_template {
    id = aws_launch_template.ecs.id
    version = "$Latest"
  }
  tag {
    key = "Name"
    value = "ecs-instance"
    propagate_at_launch = true
  }
  tag {
    key                 = "AmazonECSCluster"
    value               = var.cluster_name
    propagate_at_launch = true
  }
  lifecycle {
    create_before_destroy = true
  }
}

#Security Group for ECS Services
resource "aws_security_group" "ecs_service" {
  name = "ecs-service-sg"
  description = "Allow inbound from ALB"
  vpc_id = var.vpc_id

  ingress {
    from_port = 8000
    to_port = 8000
    protocol = "tcp"
    security_groups = [var.alb_sg_id] 
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#ECS Task Execution Role
resource "aws_iam_role" "ecs_task_exec_role" {
  name = "ecsTaskExecutionRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "ecs-tasks.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_exec_role_policy" {
  role = aws_iam_role.ecs_task_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

#Target Groups
resource "aws_lb_target_group" "backend" {
  name = "pgagi-backend-tg"
  port = var.backend_port
  protocol = "HTTP"
  vpc_id = var.vpc_id
  target_type = "instance"
  health_check {
    path = "/api/health"
    interval = 30
    timeout = 5
    healthy_threshold = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group" "frontend" {
  name = "pgagi-frontend-tg"
  port = var.frontend_port
  protocol = "HTTP"
  vpc_id = var.vpc_id
  target_type = "instance"
  health_check {
    path = "/"
    interval = 30
    timeout = 5
    healthy_threshold = 2
    unhealthy_threshold = 2
  }
}

#ECS Task Definitions and Services
resource "aws_ecs_task_definition" "backend" {
  family = "pgagi-backend"
  network_mode = "bridge"
  requires_compatibilities = ["EC2"]
  cpu = "256"
  memory = "512"
  execution_role_arn = aws_iam_role.ecs_task_exec_role.arn
  container_definitions = jsonencode([
    {
        name = "backend"
        image = "${var.ecr_backend_repo}:${var.image_tag}"
        essential=true
        portMappings = [
          { 
            containerPort = var.backend_port,
            hostPort = var.backend_port,
            protocol = "tcp"
          }
        ]
    }
  ])
}

resource "aws_ecs_task_definition" "frontend" {
  family = "pgagi-frontend"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_exec_role.arn
  container_definitions    = jsonencode([
    {
      name      = "frontend"
      image     = "${var.ecr_frontend_repo}:${var.image_tag}"
      portMappings = [
          { 
            containerPort = var.frontend_port,
            hostPort = var.frontend_port,
            protocol = "tcp"
          }
        ],
      environment = [
        {
          name  = "NEXT_PUBLIC_API_URL"
          value = var.frontend_api_url
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "backend" {
  name = "pgagi-backend"
  cluster = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.backend.arn
  launch_type = "EC2"
  desired_count = 1
  load_balancer {
    target_group_arn = aws_lb_target_group.backend.arn
    container_name = "backend"
    container_port = var.backend_port
  }

}

resource "aws_ecs_service" "frontend" {
  name = "pgagi-frontend"
  cluster = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.frontend.arn
  launch_type = "EC2"
  desired_count = 1
  load_balancer {
    target_group_arn = aws_lb_target_group.frontend.arn
    container_name = "frontend"
    container_port = var.frontend_port
  }

}




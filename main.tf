provider "aws" {
  region = "us-east-1"
}

# VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

# Public Subnets
resource "aws_subnet" "public_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "public_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1b"
}

# Security Group
resource "aws_security_group" "ecs_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create an ECR repository
resource "aws_ecr_repository" "rails_repo" {
  name                 = "rails-app-repo"
  image_tag_mutability = "MUTABLE"
}

# IAM Role for ECS
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "ecs_task_execution_policy" {
  name       = "ecsTaskExecutionRolePolicy"
  roles      = [aws_iam_role.ecs_task_execution_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECS Cluster
resource "aws_ecs_cluster" "rails_cluster" {
  name = "rails-cluster"
}

# RDS Database
resource "aws_rds_instance" "postgres" {
  allocated_storage    = 20
  engine              = "postgres"
  engine_version      = "11.6"
  instance_class      = "db.t3.micro"
  username           = "admin"
  password           = "admin123"
  publicly_accessible = false
  vpc_security_group_ids = [aws_security_group.ecs_sg.id]
  skip_final_snapshot   = true
}

# ECS Task Definition
resource "aws_ecs_task_definition" "rails_task" {
  family                   = "rails-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  memory                   = "512"
  cpu                      = "256"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      "name": "rails-container",
      "image": aws_ecr_repository.rails_repo.repository_url,
      "memory": 512,
      "cpu": 256,
      "essential": true,
      "portMappings": [
        {
          "containerPort": 80,
          "hostPort": 80
        }
      ],
      "environment": [
        {"name": "DATABASE_HOST", "value": aws_rds_instance.postgres.address},
        {"name": "DATABASE_USER", "value": "admin"},
        {"name": "DATABASE_PASSWORD", "value": "admin123"}
      ]
    }
  ])
}

# ECS Service
resource "aws_ecs_service" "rails_service" {
  name            = "rails-service"
  cluster         = aws_ecs_cluster.rails_cluster.id
  task_definition = aws_ecs_task_definition.rails_task.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = [aws_subnet.public_1.id, aws_subnet.public_2.id]
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }
}

# Autoscaling
resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 10
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.rails_cluster.name}/${aws_ecs_service.rails_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_policy" {
  name                   = "ecs-scaling-policy"
  policy_type            = "TargetTrackingScaling"
  resource_id            = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension     = "ecs:service:DesiredCount"
  service_namespace      = "ecs"

  target_tracking_scaling_policy_configuration {
    target_value = 50.0

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}

# Output ECR repository URL and ECS service URL
output "ecr_repo_url" {
  value = aws_ecr_repository.rails_repo.repository_url
}

output "ecs_service_url" {
  value = aws_ecs_service.rails_service.id
}
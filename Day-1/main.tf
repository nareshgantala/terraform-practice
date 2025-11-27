terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.22.1"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "us-east-1"
}

# VPC-1

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

# IGW-2

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "igw"
  }
}

# Public Subnet-3
resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.10.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "public"
  }
}


# Public Subnet-3
resource "aws_subnet" "public_2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.11.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "public_2"
  }
}

# Public Route Table-4
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "publicRT"
  }
}

# Associate Public Route Table with Public Subnet-5
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Associate Public Route Table with Public Subnet-5
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

# eip -6

resource "aws_eip" "lb" {
}

# ngw - 7

resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.lb.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name = "gw NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.gw]
}


# private subnet-8
resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "private"
  }
}

# private route table-9

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw.id
  }

  tags = {
    Name = "privateRT"
  }
}

# Associate Public Route Table with Public Subnet-10
resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

# create task execution role -11

resource "aws_iam_role" "ecsTaskExecutionRole" {
  name = "ecsTaskExecutionRole"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow" 
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "ecs-tasks"
  }
}

# attatch AWS managed policy to Task execution Role -11
resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.ecsTaskExecutionRole
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


# Create Target Group-12
resource "aws_lb_target_group" "tg" {
  name     = "ecs-demo-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  target_type = "ip"
}

# create alb sg -13
resource "aws_security_group" "alb_sg" {
  name        = "alb_sg"
  description = "Allow internet traffic to alb"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]

  }

  tags = {
    Name = "alb_sg"
  }
}

# create ecs task sg -14
resource "aws_security_group" "ecs_task_sg" {
  name        = "ecs_task_sg"
  description = "Allow internet traffic to alb"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
    }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]

  }

  tags = {
    Name = "ecs_task_sg"
  }
}

# create alb-15
resource "aws_lb" "ecs-demo-alb" {
  name               = "ecs-demo-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public.id,aws_subnet.public_2.id ]

  enable_deletion_protection = false


  tags = {
    Environment = "production"
  }
}

# create alb listner-16
resource "aws_lb_listener" "lb_listner" {
  load_balancer_arn = aws_lb.ecs-demo-alb.arn
  port              = "80"
  protocol          = "HTTP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

# create ecs cluster-17
resource "aws_ecs_cluster" "demo_ecs_cluster" {
  name = "demo_ecs_cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# create ecs cluster-18
resource "aws_ecs_task_definition" "demo_ecs_task" {
  family = "demo_ecs_task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn = aws_iam_role.ecsTaskExecutionRole.arn
  container_definitions = jsonencode([
    {
      name      = "demo_nginx"
      image     = "nginx:latest"
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    },
  ])
}

# ecs service

resource "aws_ecs_service" "demo_ecs_service" {
  name            = "demo_ecs_service"
  launch_type = "FARGATE"
  cluster         = aws_ecs_cluster.demo_ecs_cluster.id
  task_definition = aws_ecs_task_definition.demo_ecs_task.arn
  desired_count   = 1

  network_configuration {
    assign_public_ip = false
    security_groups = [aws_security_group.ecs_task_sg]
    subnets = [ aws_subnet.private.id ]
  }
 
  load_balancer {
    target_group_arn = aws_lb_target_group.tg.arn
    container_name   = "demo_nginx"
    container_port   = 80
  }

  depends_on = [ aws_lb_listener.lb_listner ]

}















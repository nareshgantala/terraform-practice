# create alb sg -13
resource "aws_security_group" "alb_sg" {
  name        = var.alg_sg_name
  description = "Allow internet traffic to alb"
  vpc_id      = var.vpc_id

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
  name        = var.ecs_task_sg_name
  description = "Allow internet traffic to alb"
  vpc_id      = var.vpc_id

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
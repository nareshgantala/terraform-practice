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
  execution_role_arn = var.execution_role_arn
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
    security_groups = [var.ecs_task_sg]
    subnets = [ var.private_subnet_id ]
  }
 
  load_balancer {
    target_group_arn = var.tg
    container_name   = "demo_nginx"
    container_port   = 80
  }

  depends_on = [ var.ecs_task_sg ]

}


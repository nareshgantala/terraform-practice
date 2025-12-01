# create ecs cluster-17
resource "aws_ecs_cluster" "demo_ecs_cluster" {
  name = var.cluster_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# create ecs cluster-18
resource "aws_ecs_task_definition" "demo_ecs_task" {
  family = var.cluster_family
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn = var.ecsTaskExecutionRole
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
  name            = var.ecs_service_name
  launch_type = "FARGATE"
  cluster         = aws_ecs_cluster.demo_ecs_cluster.id
  task_definition = aws_ecs_task_definition.demo_ecs_task.arn
  desired_count   = 1

  force_new_deployment = true

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


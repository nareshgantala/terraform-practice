locals {
  cluster_name = "demo-ecs-${var.environment}-cluster"
  cluster_family = "demo-ecs-taskdf-${var.environment}"
  ecs_service_name ="demo-ecs-${var.environment}-service"
  alb_tg_name = "ecs-demo-${var.environment}-tg"
  alb_name = "ecs-demo-${var.environment}-alb"
  demo-elb-listener = "elb-demo-${var.environment}-listener"
  alg_sg_name = "alb-demo-sg-${var.environment}-name"
  ecs_task_sg_name ="ecs-task-sg-${var.environment}-name"

}
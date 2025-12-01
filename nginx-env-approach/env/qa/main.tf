module "security" {
  source = "../../modules/security"
  vpc_id = var.vpc_id
  alg_sg_name = local.alg_sg_name
  ecs_task_sg_name = local.ecs_task_sg_name
}

module "alb" {
  source = "../../modules/alb"
  public_subnet_1_id = data.aws_subnet.private_subnet_1.id
  public_subnet_2_id = data.aws_subnet.public_subnet_2.id
  vpc_id = var.vpc_id
  alb_sg = module.security.alb_sg
  alb_tg_name = local.alb_tg_name
  demo-elb-listener_name = local.demo-elb-listener
  alb_name = local.alb_name
}


module "ecs" {
  source = "../../modules/ecs"
  ecs_task_sg = module.security.ecs_task_sg
  tg = module.alb.tg
  private_subnet_id = data.aws_subnet.private_subnet_1.id
  cluster_name = local.cluster_name
  cluster_family = local.cluster_family
  ecs_service_name = local.ecs_service_name
  ecsTaskExecutionRole = data.aws_iam_role.ecsTaskExecutionRole.arn
}
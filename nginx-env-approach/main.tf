module "security" {
  source = "./modules/security"
  vpc_id = var.vpc_id
}

module "alb" {
  source = "./modules/alb"
  public_subnet_1_id = data.aws_subnet.private_subnet_1.id
  public_subnet_2_id = data.aws_subnet.public_subnet_2.id
  vpc_id = var.vpc_id
  alb_sg = module.security.alb_sg
}

module "iam" {
  source = "./modules/iam"
  policy_arn = var.policy_arn
}

module "ecs" {
  source = "./modules/ecs"
  execution_role_arn = module.iam.execution_role_arn
  ecs_task_sg = module.security.ecs_task_sg
  tg = module.alb.tg
  private_subnet_id = data.aws_subnet.private_subnet_1.id
}
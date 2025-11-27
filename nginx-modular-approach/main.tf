module "networking" {
  source = "./modules/networking"
  vpc_cidr = "10.0.0.0/16"
}

module "iam" {
  source = "./modules/iam"
}

module "alb" {
  source = "./modules/alb"
  vpc_id = module.networking.vpc_id
  public_subnet_1_id = module.networking.public_subnet_1_id
  public_subnet_2_id = module.networking.public_subnet_2_id
  alb_sg = module.networking.alb_sg
}

module "ecs" {
  source = "./modules/ecs"
  execution_role_arn = module.iam.execution_role_arn
  ecs_task_sg = module.networking.ecs_task_sg
  private_subnet_id = module.networking.private_subnet_id
  tg = module.alb.tg
}



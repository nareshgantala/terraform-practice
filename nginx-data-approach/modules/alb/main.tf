# Create Target Group-12
resource "aws_lb_target_group" "tg" {
  name     = "ecs-demo-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "ip"
}



# create alb-15
resource "aws_lb" "ecs-demo-alb" {
  name               = "ecs-demo-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg]
  subnets            = [var.public_subnet_1_id,var.public_subnet_2_id]

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
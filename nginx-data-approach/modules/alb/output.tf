output "tg" {
  value = aws_lb_target_group.tg.arn
}

output "alb_dns_name" {
  value = aws_lb.ecs-demo-alb.dns_name
}
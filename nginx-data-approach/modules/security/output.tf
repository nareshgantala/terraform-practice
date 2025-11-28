output "alb_sg" {
  value = aws_security_group.alb_sg.id
}


output "ecs_task_sg" {
  value = aws_security_group.ecs_task_sg.id
}
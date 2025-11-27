output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_1_id" {
  value = aws_subnet.public[0].id
}

output "public_subnet_2_id" {
  value = aws_subnet.public[1].id
}

output "private_subnet_id" {
  value = aws_subnet.private.id
}

output "alb_sg" {
  value = aws_security_group.alb_sg.id
}

output "ecs_task_sg" {
  value = aws_security_group.ecs_task_sg.id
}
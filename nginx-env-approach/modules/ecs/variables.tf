# variable "execution_role_arn" {
#   type = string
# }

variable "ecs_task_sg" {
  type = string
}

variable "tg" {
  type = string
}

variable "private_subnet_id" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "cluster_family" {
  type = string
}

variable "ecs_service_name" {
  
}

variable "ecsTaskExecutionRole" {
  type = string
}
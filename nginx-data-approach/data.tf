data "aws_vpc" "name" {
  id = var.vpc_id
}

data "aws_subnet" "public_subnet_1" {
  filter {
    name   = "tag:Name"
    values = ["ecs-demo-subnet-public1-us-east-1a"]
  }
}

data "aws_subnet" "public_subnet_2" {
  filter {
    name   = "tag:Name"
    values = ["ecs-demo-subnet-public2-us-east-1b"]
  }
}


data "aws_subnet" "private_subnet_1" {
  filter {
    name   = "tag:Name"
    values = ["ecs-demo-subnet-private1-us-east-1a"]
  }
}

data "aws_subnet" "private_subnet_2" {
  filter {
    name   = "tag:Name"
    values = ["ecs-demo-subnet-private2-us-east-1b"]
  }
}

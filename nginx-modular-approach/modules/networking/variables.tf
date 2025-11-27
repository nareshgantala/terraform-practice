variable "vpc_cidr" {
  type = string
}

variable "availability_zones" {
  type = list(string)
  default = [ "us-east-1a", "us-east-1b" ]
}

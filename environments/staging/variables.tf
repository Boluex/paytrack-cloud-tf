variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "project_name" {
  type    = string
  default = "paytrack"
}

variable "environment" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "azs" {
  type = list(string)
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "private_subnet_cidrs" {
  type = list(string)
}

variable "single_nat_gateway" {
  description = "Use one shared NAT GW instead of one per AZ (cost savings for non-prod)"
  type        = bool
  default     = true
}

variable "container_image" {
  type = string
}

variable "container_port" {
  type    = number
  default = 8080
}

variable "ecs_desired_count" {
  type    = number
  default = 2
}

variable "ecs_min_capacity" {
  type    = number
  default = 2
}

variable "ecs_max_capacity" {
  type    = number
  default = 10
}

variable "ecs_task_cpu" {
  type    = number
  default = 512
}

variable "ecs_task_memory" {
  type    = number
  default = 1024
}

variable "certificate_arn" {
  type    = string
  default = ""
}

variable "ec2_instance_type" {
  type    = string
  default = "t3.micro"
}

variable "ec2_min_size" {
  type    = number
  default = 1
}

variable "ec2_max_size" {
  type    = number
  default = 3
}

variable "ec2_desired_capacity" {
  type    = number
  default = 1
}

variable "ami_id" {
  type        = string
  description = "AMI ID to use for EC2 instances"
  default     = "ami-mock"
}

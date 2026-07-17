variable "environment" {
    type        = string
    description = "Environment name (dev / test / prod)"
}

variable "project_name" {
    type        = string
    description = "Project name"
}

variable "aws_region" {
    type        = string
    description = "AWS region"
}

variable "vpc_cidr" {
    type        = string
    description = "VPC CIDR"
}

variable "azs" {
    type        = list(string)
    description = "List of AZs"
}

variable "public_subnet_cidrs" {
    type        = list(string)
    description = "List of public subnet CIDRs"
}

variable "private_subnet_cidrs" {
    type        = list(string)
    description = "List of private subnet CIDRs"
}

variable "single_nat_gateway" {
    type        = bool
    description = "Whether to use a single NAT gateway"
}

variable "container_image" {
    type        = string
    description = "Container image"
}

variable "container_port" {
    type        = number
    description = "Container port"
}

variable "ecs_task_cpu" {
    type        = number
    description = "ECS task CPU"
}

variable "ecs_task_memory" {
    type        = number
    description = "ECS task memory"
}

variable "ecs_desired_count" {
    type        = number
    description = "ECS desired count"
}

variable "ecs_min_capacity" {
    type        = number
    description = "ECS min capacity"
}

variable "ecs_max_capacity" {
    type        = number
    description = "ECS max capacity"
}

variable "ec2_instance_type" {
    type        = string
    description = "EC2 instance type"
}

variable "ec2_min_size" {
    type        = number
    description = "EC2 min size"
}

variable "ec2_max_size" {
    type        = number
    description = "EC2 max size"
}

variable "ec2_desired_capacity" {
    type        = number
    description = "EC2 desired capacity"
}
environment  = "staging"
project_name = "paytrack"
aws_region   = "us-east-1"

vpc_cidr             = "10.1.0.0/16"
azs                  = ["us-east-1a", "us-east-1b"]
public_subnet_cidrs  = ["10.1.0.0/24", "10.1.1.0/24"]
private_subnet_cidrs = ["10.1.10.0/24", "10.1.11.0/24"]
single_nat_gateway   = true

container_image   = "123456789012.dkr.ecr.us-east-1.amazonaws.com/paytrack:latest"
container_port    = 8080
ecs_desired_count = 2
ecs_min_capacity  = 2
ecs_max_capacity  = 6
ecs_task_cpu      = 512
ecs_task_memory   = 1024

ec2_instance_type    = "t3.small"
ec2_min_size         = 1
ec2_max_size         = 2
ec2_desired_capacity = 1
ami_id               = "ami-mock"


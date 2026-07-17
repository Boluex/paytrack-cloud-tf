environment = "prod"
project_name = "paytrack"
aws_region   = "us-east-1"

vpc_cidr             = "10.2.0.0/16"
azs                  = ["us-east-1a", "us-east-1b", "us-east-1c"]
public_subnet_cidrs  = ["10.2.0.0/24", "10.2.1.0/24", "10.2.2.0/24"]
private_subnet_cidrs = ["10.2.10.0/24", "10.2.11.0/24", "10.2.12.0/24"]
single_nat_gateway   = false # one NAT GW per AZ for HA in prod

container_image   = "123456789012.dkr.ecr.us-east-1.amazonaws.com/myapp:latest"
container_port    = 8080
ecs_desired_count = 3
ecs_min_capacity  = 3
ecs_max_capacity  = 20
ecs_task_cpu      = 1024
ecs_task_memory   = 2048

# certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/xxxxx" # set for HTTPS

ec2_instance_type    = "t3.medium"
ec2_min_size         = 2
ec2_max_size         = 6
ec2_desired_capacity = 2
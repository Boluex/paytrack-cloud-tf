variable "name_prefix" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "alb_sg_id" {
  type = string
}

variable "ecs_service_sg_id" {
  type = string
}

variable "container_image" {
  description = "Full ECR image URI, e.g. 123456789012.dkr.ecr.us-east-1.amazonaws.com/app:latest"
  type        = string
}

variable "container_port" {
  type    = number
  default = 8080
}

variable "task_cpu" {
  type    = number
  default = 512
}

variable "task_memory" {
  type    = number
  default = 1024
}

variable "desired_count" {
  type    = number
  default = 2
}

variable "min_capacity" {
  type    = number
  default = 2
}

variable "max_capacity" {
  type    = number
  default = 10
}

variable "health_check_path" {
  type    = string
  default = "/health"
}

variable "environment_variables" {
  description = "Plain (non-secret) environment variables for the container"
  type        = map(string)
  default     = {}
}

variable "secrets" {
  description = "Map of container env var name -> Secrets Manager or SSM ARN"
  type        = map(string)
  default     = {}
}

variable "log_retention_days" {
  type    = number
  default = 30
}

variable "enable_execute_command" {
  description = "Enable ECS Exec for debugging (should be false in prod)"
  type        = bool
  default     = false
}

variable "certificate_arn" {
  description = "ACM certificate ARN for HTTPS listener. Leave empty to only serve HTTP."
  type        = string
  default     = ""
}

variable "tags" {
  type    = map(string)
  default = {}
}

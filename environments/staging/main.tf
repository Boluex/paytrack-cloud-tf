locals {
  name_prefix = "${var.project_name}-${var.environment}"
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}

############################################
# Networking
############################################
module "vpc" {
  source = "../../modules/vpc"

  name_prefix          = local.name_prefix
  vpc_cidr             = var.vpc_cidr
  azs                  = var.azs
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  single_nat_gateway   = var.single_nat_gateway
  tags                 = local.common_tags
}

module "security_groups" {
  source = "../../modules/security-groups"

  name_prefix = local.name_prefix
  vpc_id      = module.vpc.vpc_id
  vpc_cidr    = module.vpc.vpc_cidr
  tags        = local.common_tags
}

############################################
# Secrets (app config, DB creds)
############################################
module "secrets" {
  source = "../../modules/secrets"

  name_prefix = local.name_prefix

  secrets = {
    "app-config" = {
      description     = "Application configuration secrets for ${var.environment}"
      generate_random = false
    }
    "db-credentials" = {
      description     = "Database credentials for ${var.environment}"
      generate_random = true
    }
  }

  recovery_window_in_days = var.environment == "prod" ? 30 : 0
  tags                    = local.common_tags
}

############################################
# Messaging: SNS -> SQS with DLQ
############################################
module "events" {
  source = "../../modules/sns-sqs"

  name_prefix = local.name_prefix
  topic_name  = "app-events"
  queue_name  = "app-events-queue"
  tags        = local.common_tags
}

############################################
# DynamoDB
############################################
module "dynamodb_table" {
  source = "../../modules/dynamodb"

  name_prefix = local.name_prefix
  table_name  = "app-data"
  hash_key    = "PK"
  range_key   = "SK"

  attributes = [
    { name = "PK", type = "S" },
    { name = "SK", type = "S" }
  ]

  enable_streams = true
  tags           = local.common_tags
}

############################################
# ECS Fargate (main application)
############################################
module "ecs" {
  source = "../../modules/ecs-fargate"

  name_prefix        = local.name_prefix
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
  alb_sg_id          = module.security_groups.alb_sg_id
  ecs_service_sg_id  = module.security_groups.ecs_service_sg_id

  container_image = var.container_image
  container_port  = var.container_port
  task_cpu        = var.ecs_task_cpu
  task_memory     = var.ecs_task_memory
  desired_count   = var.ecs_desired_count
  min_capacity    = var.ecs_min_capacity
  max_capacity    = var.ecs_max_capacity

  certificate_arn        = var.certificate_arn
  enable_execute_command = var.environment != "prod"

  environment_variables = {
    ENVIRONMENT    = var.environment
    DYNAMODB_TABLE = module.dynamodb_table.table_name
    SNS_TOPIC_ARN  = module.events.topic_arn
    SQS_QUEUE_URL  = module.events.queue_url
  }

  secrets = {
    APP_CONFIG_SECRET = module.secrets.secret_arns["app-config"]
    DB_CREDENTIALS    = module.secrets.secret_arns["db-credentials"]
  }

  tags = local.common_tags
}

############################################
# EC2 (batch/worker fleet)
############################################
module "ec2" {
  source = "../../modules/ec2"

  name_prefix        = local.name_prefix
  private_subnet_ids = module.vpc.private_subnet_ids
  ec2_sg_id          = module.security_groups.ec2_sg_id
  instance_type      = var.ec2_instance_type
  min_size           = var.ec2_min_size
  max_size           = var.ec2_max_size
  desired_capacity   = var.ec2_desired_capacity

  user_data = <<-EOT
      #!/bin/bash
      dnf install -y amazon-cloudwatch-agent
    EOT

  tags = local.common_tags
}

############################################
# Lambda (async event processor)
############################################
module "event_processor_lambda" {
  source = "../../modules/lambda"

  name_prefix   = local.name_prefix
  function_name = "event-processor"
  source_dir    = "${path.module}/../../lambda-src/event-processor"
  handler       = "index.handler"
  runtime       = "nodejs20.x"

  sqs_trigger_arn     = module.events.queue_arn
  dynamodb_table_arns = [module.dynamodb_table.table_arn]

  environment_variables = {
    ENVIRONMENT    = var.environment
    DYNAMODB_TABLE = module.dynamodb_table.table_name
  }

  tags = local.common_tags
}

############################################
# CloudWatch: dashboard + alarms
############################################
module "cloudwatch" {
  source = "../../modules/cloudwatch"

  name_prefix         = local.name_prefix
  ecs_cluster_name    = module.ecs.cluster_name
  ecs_service_name    = module.ecs.service_name
  asg_name            = module.ec2.asg_name
  alb_arn_suffix      = module.ecs.alb_arn_suffix
  sns_alarm_topic_arn = module.events.topic_arn

  tags = local.common_tags
}
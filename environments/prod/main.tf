locals {
    name_prefix = "${var.project_name}-${var.environment}"
    common_tags = {
        Environment = var.environment
        ManagedBy   = "terraform"
        Project     = var.project_name
    }
}


module "vpc" {
    source     = "../modules/vpc"
    name_prefix = local.name_prefix
    cidr_block  = var.vpc_cidr
    azs         = var.azs
    public_subnet_cidrs  = var.public_subnet_cidrs
    private_subnet_cidrs = var.private_subnet_cidrs
    tags         = local.common_tags
}

module "security_groups" {
    source = "../modules/security-groups"
    name_prefix = local.name_prefix
    vpc_id      = module.vpc.vpc_id
    common_tags = local.common_tags
}

module "secrets" {
    source = "../modules/secrets"
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
    
    tags = local.common_tags
}

module "sns_sqs" {
    source = "../modules/sns-sqs"
    name_prefix = local.name_prefix
    topic_name = "app-events"
    queue_name = "app-events-queue"
    tags = local.common_tags
}

module "dynamodb_table" {
    source = "../modules/dynamodb"
    name_prefix = local.name_prefix
    common_tags = local.common_tags
    table_name = "paytrack-table"
    hash_key = "pk"
    range_key = "pk"
    
    attributes = [
        { name = "pk", type = "S" },
        { name = "sk", type = "S" },
    ]

    enable_streams = true
    tags = local.common_tags

}

module "ecs_fargate" {
    source = "../modules/ecs-fargate"
    name_prefix = local.name_prefix
    common_tags = local.common_tags
    container_image = var.container_image
    container_port = var.container_port
    ecs_desired_count = var.ecs_desired_count
    ecs_min_capacity = var.ecs_min_capacity
    ecs_max_capacity = var.ecs_max_capacity
    ecs_task_cpu = var.ecs_task_cpu
    ecs_task_memory = var.ecs_task_memory
    certificate_arn = var.certificate_arn
    enable_execute_command = var.environment != "prod"
    environment_variables = {
        ENVIRONMENT = var.environment
        DYNAMODB_TABLE = module.dynamodb_table.table_name
        SNS_TOPIC_ARN = module.sns_sqs.topic_arn
        SQS_QUEUE_URL = module.sns_sqs.queue_url
    }
    secrets = {
        APP_CONFIG_SECRET = module.secrets.secret_arns["app-config"]
        DB_CREDENTIALS     = module.secrets.secret_arns["db-credentials"]
    }
    tags = local.common_tags
}

module "ec2" {
    source = "../modules/ec2"
    name_prefix = local.name_prefix
    common_tags = local.common_tags
    ec2_ami_id = var.ec2_ami_id
    ec2_instance_type = var.ec2_instance_type
    ec2_min_count = var.ec2_min_count
    ec2_max_count = var.ec2_max_count
    certificate_arn = var.certificate_arn
    enable_execute_command = var.environment != "prod"
    environment_variables = {
        ENVIRONMENT = var.environment
        DYNAMODB_TABLE = module.dynamodb_table.table_name
        SNS_TOPIC_ARN = module.sns_sqs.topic_arn
        SQS_QUEUE_URL = module.sns_sqs.queue_url
    }
    secrets = {
        APP_CONFIG_SECRET = module.secrets.secret_arns["app-config"]
        DB_CREDENTIALS     = module.secrets.secret_arns["db-credentials"]
    }
    tags = local.common_tags
}

module "lambda" {
    source = "../modules/lambda"
    name_prefix = local.name_prefix
    common_tags = local.common_tags
    source_dir = "lambda-src/${var.environment}"
    handler = "index.handler"
    runtime = "nodejs20.x"
    timeout = 30
    memory_size = 128
    environment_variables = {
        ENVIRONMENT = var.environment
        DYNAMODB_TABLE = module.dynamodb_table.table_name
        SNS_TOPIC_ARN = module.sns_sqs.topic_arn
        SQS_QUEUE_URL = module.sns_sqs.queue_url
    }
    secrets = {
        APP_CONFIG_SECRET = module.secrets.secret_arns["app-config"]
        DB_CREDENTIALS     = module.secrets.secret_arns["db-credentials"]
    }
    tags = local.common_tags
}

module "cloudwatch" {
    source = "../modules/cloudwatch"
    name_prefix = local.name_prefix
    common_tags = local.common_tags
    ecs_cluster_name = module.ecs_fargate.cluster_name
    ecs_service_name = module.ecs_fargate.service_name
    asg_name = module.ec2.asg_name
    alb_arn_suffix = module.alb.alb_arn_suffix
    sns_alarm_topic_arn = module.sns_sqs.topic_arn
    tags = local.common_tags
}

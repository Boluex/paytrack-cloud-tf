terraform {
  required_version = ">= 1.7.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4"
    }
  }
}

provider "aws" {
  region     = var.aws_region
  access_key = var.use_local_emulator ? "test" : null
  secret_key = var.use_local_emulator ? "test" : null

  skip_credentials_validation = var.use_local_emulator
  skip_metadata_api_check     = var.use_local_emulator
  skip_requesting_account_id  = var.use_local_emulator

  default_tags {
    tags = {
      Environment = var.environment
      ManagedBy   = "terraform"
      Project     = var.project_name
    }
  }

  endpoints {
    ec2                    = var.use_local_emulator ? var.ec2_endpoint : null
    s3                     = var.use_local_emulator ? var.aws_endpoint : null
    dynamodb               = var.use_local_emulator ? var.aws_endpoint : null
    sns                    = var.use_local_emulator ? var.aws_endpoint : null
    sqs                    = var.use_local_emulator ? var.aws_endpoint : null
    secretsmanager         = var.use_local_emulator ? var.aws_endpoint : null
    lambda                 = var.use_local_emulator ? var.aws_endpoint : null
    cloudwatch             = var.use_local_emulator ? var.aws_endpoint : null
    cloudwatchlogs         = var.use_local_emulator ? var.aws_endpoint : null
    iam                    = var.use_local_emulator ? var.aws_endpoint : null
    sts                    = var.use_local_emulator ? var.aws_endpoint : null
    ssm                    = var.use_local_emulator ? var.aws_endpoint : null
    ecs                    = var.use_local_emulator ? var.aws_endpoint : null
    elasticloadbalancingv2 = var.use_local_emulator ? var.aws_endpoint : null
    autoscaling            = var.use_local_emulator ? var.aws_endpoint : null
    applicationautoscaling = var.use_local_emulator ? var.aws_endpoint : null
    acm                    = var.use_local_emulator ? var.aws_endpoint : null
    kms                    = var.use_local_emulator ? var.aws_endpoint : null
  }
}
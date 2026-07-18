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
  access_key = "test"
  secret_key = "test"

  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  default_tags {
    tags = {
      Environment = var.environment
      ManagedBy   = "terraform"
      Project     = var.project_name
    }
  }

  endpoints {
    ec2                    = "http://localhost:5003"
    s3                     = "http://localhost:4566"
    dynamodb               = "http://localhost:4566"
    sns                    = "http://localhost:4566"
    sqs                    = "http://localhost:4566"
    secretsmanager         = "http://localhost:4566"
    lambda                 = "http://localhost:4566"
    cloudwatch             = "http://localhost:4566"
    cloudwatchlogs         = "http://localhost:4566"
    iam                    = "http://localhost:4566"
    sts                    = "http://localhost:4566"
    ssm                    = "http://localhost:4566"
    ecs                    = "http://localhost:4566"
    elasticloadbalancingv2 = "http://localhost:4566"
    applicationautoscaling = "http://localhost:4566"
    acm                    = "http://localhost:4566"
    kms                    = "http://localhost:4566"
  }
}
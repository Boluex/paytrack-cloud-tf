terraform {
    required_version = ">= 1.7.0"
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 5.0"
        }
    }
}

provider "aws" {
    region = var.aws_region
}

variable "aws_region" {
    type = string
    default = "us-east-1"
}


variable "github_org" {
    type = string
}

variable "github_repo" {
    type = string
}

data "aws_iam_openid_connect_provider" "github" {
    count= var.create_oidc_provider ? 0 : 1
    url   = "https://token.actions.githubusercontent.com"
}

variable "create_oidc_provider" {
    type = bool
    default = false
}

resource "aws_iam_openid_connect_provider" "github" {
    count= var.create_oidc_provider ? 0 : 1
    url   = "https://token.actions.githubusercontent.com"
    client_id_list = [
        "sts.amazonaws.com",
    ]
    thumbprint_list = ["a0719949b06601e66f8d69e40207428b51c14970" 
    ]
}

locals {
    oidc_provider_arn = var.create_oidc_provider ? aws_iam_openid_connect_provider.github[0].arn : data.aws_iam_openid_connect_provider.github[0].arn
}

resource "aws_iam_role" "github_actions" {
  name = "paytrack-github-actions"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = local.oidc_provider_arn }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
        StringLike = {
          # Restrict to a specific repo; add ':ref:refs/heads/main' etc. to lock down further per branch
          "token.actions.githubusercontent.com:sub" = "repo:${var.github_org}/${var.github_repo}:*"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "github_actions_admin" {
    role = aws_iam_role.github_actions.name
    policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

output "github_actions_role_arn" {
    value = aws_iam_role.github_actions.arn
}
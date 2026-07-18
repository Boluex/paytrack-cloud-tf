variable "name_prefix" {
  type = string
}

variable "function_name" {
  type = string
}

variable "source_dir" {
  description = "Local directory containing the Lambda source code, zipped by Terraform"
  type        = string
}

variable "handler" {
  type    = string
  default = "index.handler"
}

variable "runtime" {
  type    = string
  default = "nodejs20.x"
}

variable "timeout" {
  type    = number
  default = 30
}

variable "memory_size" {
  type    = number
  default = 256
}

variable "environment_variables" {
  type    = map(string)
  default = {}
}

variable "vpc_subnet_ids" {
  description = "Set to attach the Lambda to the VPC (needed to reach RDS/private resources). Leave empty for internet-only functions."
  type        = list(string)
  default     = []
}

variable "vpc_security_group_ids" {
  type    = list(string)
  default = []
}

variable "sqs_trigger_arn" {
  description = "SQS queue ARN to use as an event source (optional)"
  type        = string
  default     = ""
}

variable "enable_sqs_trigger" {
  description = "Whether to enable the SQS queue trigger for the Lambda function"
  type        = bool
  default     = false
}

variable "extra_policy_statements" {
  description = "Extra IAM policy statements (list of objects matching aws_iam_policy_document 'statement' shape) as JSON-ready maps"
  type        = list(any)
  default     = []
}

variable "dynamodb_table_arns" {
  type    = list(string)
  default = []
}

variable "log_retention_days" {
  type    = number
  default = 30
}

variable "reserved_concurrent_executions" {
  type    = number
  default = -1
}

variable "tags" {
  type    = map(string)
  default = {}
}

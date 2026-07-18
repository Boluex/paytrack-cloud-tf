data "archive_file" "this" {
  type        = "zip"
  source_dir  = var.source_dir
  output_path = "${path.module}/.build/${var.function_name}.zip"
}

############################################
# IAM Role
############################################
resource "aws_iam_role" "this" {
  name = "${var.name_prefix}-${var.function_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "basic_execution" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "vpc_execution" {
  count      = length(var.vpc_subnet_ids) > 0 ? 1 : 0
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy" "sqs_trigger" {
  count = var.sqs_trigger_arn == "" ? 0 : 1
  name  = "${var.name_prefix}-${var.function_name}-sqs"
  role  = aws_iam_role.this.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"]
      Resource = var.sqs_trigger_arn
    }]
  })
}

resource "aws_iam_role_policy" "dynamodb" {
  count = length(var.dynamodb_table_arns) > 0 ? 1 : 0
  name  = "${var.name_prefix}-${var.function_name}-dynamodb"
  role  = aws_iam_role.this.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:UpdateItem",
        "dynamodb:DeleteItem",
        "dynamodb:Query",
        "dynamodb:Scan"
      ]
      Resource = concat(var.dynamodb_table_arns, [for arn in var.dynamodb_table_arns : "${arn}/index/*"])
    }]
  })
}

resource "aws_iam_role_policy" "extra" {
  count = length(var.extra_policy_statements) > 0 ? 1 : 0
  name  = "${var.name_prefix}-${var.function_name}-extra"
  role  = aws_iam_role.this.id

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = var.extra_policy_statements
  })
}

############################################
# Log Group (created explicitly so retention is controlled)
############################################
resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/lambda/${var.name_prefix}-${var.function_name}"
  retention_in_days = var.log_retention_days
  tags              = var.tags
}

############################################
# Lambda Function
############################################
resource "aws_lambda_function" "this" {
  function_name = "${var.name_prefix}-${var.function_name}"
  role          = aws_iam_role.this.arn
  handler       = var.handler
  runtime       = var.runtime
  timeout       = var.timeout
  memory_size   = var.memory_size

  filename         = data.archive_file.this.output_path
  source_code_hash = data.archive_file.this.output_base64sha256

  reserved_concurrent_executions = var.reserved_concurrent_executions

  dynamic "vpc_config" {
    for_each = length(var.vpc_subnet_ids) > 0 ? [1] : []
    content {
      subnet_ids         = var.vpc_subnet_ids
      security_group_ids = var.vpc_security_group_ids
    }
  }

  environment {
    variables = var.environment_variables
  }

  tracing_config {
    mode = "Active"
  }

  depends_on = [aws_cloudwatch_log_group.this]
  tags       = var.tags
}

############################################
# SQS Event Source Mapping (optional)
############################################
resource "aws_lambda_event_source_mapping" "sqs" {
  count            = var.sqs_trigger_arn == "" ? 0 : 1
  event_source_arn = var.sqs_trigger_arn
  function_name    = aws_lambda_function.this.arn
  batch_size       = 10
  enabled          = true
}

############################################
# Error alarm
############################################
resource "aws_cloudwatch_metric_alarm" "errors" {
  alarm_name          = "${var.name_prefix}-${var.function_name}-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Sum"
  threshold           = 0
  treat_missing_data  = "notBreaching"
  alarm_description   = "Lambda ${var.name_prefix}-${var.function_name} reported errors"

  dimensions = {
    FunctionName = aws_lambda_function.this.function_name
  }

  tags = var.tags
}

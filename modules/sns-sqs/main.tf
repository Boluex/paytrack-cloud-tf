############################################
# SNS Topic (encrypted with default KMS key)
############################################
resource "aws_sns_topic" "this" {
  name              = "${var.name_prefix}-${var.topic_name}"
  kms_master_key_id = "alias/aws/sns"
  tags              = var.tags
}

############################################
# Dead Letter Queue
############################################
resource "aws_sqs_queue" "dlq" {
  name                      = "${var.name_prefix}-${var.queue_name}-dlq"
  message_retention_seconds = 1209600 # 14 days
  kms_master_key_id         = "alias/aws/sqs"
  tags                      = var.tags
}

############################################
# Main Queue
############################################
resource "aws_sqs_queue" "this" {
  name                       = "${var.name_prefix}-${var.queue_name}"
  visibility_timeout_seconds = var.visibility_timeout_seconds
  message_retention_seconds  = var.message_retention_seconds
  kms_master_key_id          = "alias/aws/sqs"

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = var.max_receive_count
  })

  tags = var.tags
}

resource "aws_sqs_queue_policy" "allow_sns" {
  queue_url = aws_sqs_queue.this.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "AllowSNSPublish"
      Effect    = "Allow"
      Principal = { Service = "sns.amazonaws.com" }
      Action    = "sqs:SendMessage"
      Resource  = aws_sqs_queue.this.arn
      Condition = {
        ArnEquals = { "aws:SourceArn" = aws_sns_topic.this.arn }
      }
    }]
  })
}

resource "aws_sns_topic_subscription" "sqs" {
  topic_arn            = aws_sns_topic.this.arn
  protocol             = "sqs"
  endpoint             = aws_sqs_queue.this.arn
  raw_message_delivery = true
}

############################################
# DLQ alarm - anything landing here needs attention
############################################
resource "aws_cloudwatch_metric_alarm" "dlq_not_empty" {
  alarm_name          = "${var.name_prefix}-${var.queue_name}-dlq-not-empty"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 300
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "Messages present in DLQ ${var.name_prefix}-${var.queue_name}-dlq"
  treat_missing_data  = "notBreaching"

  dimensions = {
    QueueName = aws_sqs_queue.dlq.name
  }

  tags = var.tags
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "alb_dns_name" {
  value = module.ecs.alb_dns_name
}

output "ecs_cluster_name" {
  value = module.ecs.cluster_name
}

output "dynamodb_table_name" {
  value = module.dynamodb_table.table_name
}

output "sns_topic_arn" {
  value = module.events.topic_arn
}

output "sqs_queue_url" {
  value = module.events.queue_url
}

output "lambda_function_name" {
  value = module.event_processor_lambda.function_name
}

output "secret_arns" {
  value     = module.secrets.secret_arns
  sensitive = true
}

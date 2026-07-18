output "alb_sg_id" {
  value = aws_security_group.alb.id
}

output "ecs_service_sg_id" {
  value = aws_security_group.ecs_service.id
}

output "ec2_sg_id" {
  value = aws_security_group.ec2.id
}

output "lambda_sg_id" {
  value = aws_security_group.lambda.id
}

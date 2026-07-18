variable "name_prefix" {
  type = string
}

variable "ecs_cluster_name" {
  type    = string
  default = ""
}

variable "ecs_service_name" {
  type    = string
  default = ""
}

variable "asg_name" {
  type    = string
  default = ""
}

variable "alb_arn_suffix" {
  type    = string
  default = ""
}

variable "sns_alarm_topic_arn" {
  description = "SNS topic ARN to notify on alarm state"
  type        = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

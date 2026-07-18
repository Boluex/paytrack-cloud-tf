variable "name_prefix" {
  type = string
}

variable "topic_name" {
  type = string
}

variable "queue_name" {
  type = string
}

variable "visibility_timeout_seconds" {
  type    = number
  default = 60
}

variable "message_retention_seconds" {
  type    = number
  default = 345600 # 4 days
}

variable "max_receive_count" {
  description = "Number of receives before message goes to DLQ"
  type        = number
  default     = 5
}

variable "tags" {
  type    = map(string)
  default = {}
}

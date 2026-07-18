variable "name_prefix" {
  type = string
}

variable "ami_id" {
  description = "AMI ID to use for EC2 instances. If empty, looks up latest AL2023 AMI from SSM."
  type        = string
  default     = ""
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "ec2_sg_id" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "min_size" {
  type    = number
  default = 1
}

variable "max_size" {
  type    = number
  default = 3
}

variable "desired_capacity" {
  type    = number
  default = 1
}

variable "key_name" {
  description = "EC2 key pair name (optional - SSM Session Manager is preferred over SSH)"
  type        = string
  default     = null
}

variable "user_data" {
  description = "Base64 or plain user_data script"
  type        = string
  default     = ""
}

variable "tags" {
  type    = map(string)
  default = {}
}

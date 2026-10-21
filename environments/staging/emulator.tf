variable "use_local_emulator" {
  description = "Use local Ministack endpoints instead of AWS; disable explicitly for cloud plans."
  type        = bool
  default     = true
}
variable "ec2_endpoint" {
  description = "Ministack EC2 endpoint; use port 4566 for unified emulators."
  type        = string
  default     = "http://localhost:5003"
}
variable "aws_endpoint" {
  description = "Local AWS API endpoint."
  type        = string
  default     = "http://localhost:4566"
}

variable "name_prefix" {
  type = string
}

variable "secrets" {
  description = <<-EOT
    Map of secret_key -> { description, generate_random (bool), secret_value (optional plain map/string, only used if generate_random = false) }
    NOTE: For real secret VALUES, prefer setting them out-of-band (AWS console/CLI, or a secure CI secret)
    rather than committing them to tfvars. This module creates the Secrets Manager container;
    aws_secretsmanager_secret_version below only seeds a placeholder or random value.
  EOT
  type = map(object({
    description     = string
    generate_random = optional(bool, true)
  }))
}

variable "recovery_window_in_days" {
  description = "Days before a deleted secret is purged. Set 0 for immediate delete in dev."
  type        = number
  default     = 7
}

variable "tags" {
  type    = map(string)
  default = {}
}

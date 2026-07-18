variable "name_prefix" {
  type = string
}

variable "table_name" {
  type = string
}

variable "hash_key" {
  type = string
}

variable "range_key" {
  type    = string
  default = null
}

variable "attributes" {
  description = "List of { name, type } for hash/range/GSI keys. type is S, N, or B"
  type = list(object({
    name = string
    type = string
  }))
}

variable "billing_mode" {
  type    = string
  default = "PAY_PER_REQUEST"
}

variable "global_secondary_indexes" {
  description = "Optional list of GSIs"
  type = list(object({
    name            = string
    hash_key        = string
    range_key       = optional(string)
    projection_type = string
  }))
  default = []
}

variable "enable_streams" {
  type    = bool
  default = false
}

variable "ttl_attribute" {
  type    = string
  default = ""
}

variable "tags" {
  type    = map(string)
  default = {}
}

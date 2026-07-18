resource "aws_dynamodb_table" "this" {
  name         = "${var.name_prefix}-${var.table_name}"
  billing_mode = var.billing_mode
  hash_key     = var.hash_key
  range_key    = var.range_key

  dynamic "attribute" {
    for_each = var.attributes
    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }

  dynamic "global_secondary_index" {
    for_each = var.global_secondary_indexes
    content {
      name            = global_secondary_index.value.name
      hash_key        = global_secondary_index.value.hash_key
      range_key       = try(global_secondary_index.value.range_key, null)
      projection_type = global_secondary_index.value.projection_type
    }
  }

  dynamic "ttl" {
    for_each = var.ttl_attribute == "" ? [] : [1]
    content {
      attribute_name = var.ttl_attribute
      enabled        = true
    }
  }

  stream_enabled   = var.enable_streams
  stream_view_type = var.enable_streams ? "NEW_AND_OLD_IMAGES" : null

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled = true
  }

  tags = var.tags
}

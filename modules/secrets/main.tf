resource "aws_secretsmanager_secret" "this" {
  for_each = var.secrets

  name                    = "${var.name_prefix}/${each.key}"
  description             = each.value.description
  recovery_window_in_days = var.recovery_window_in_days
  tags                    = var.tags
}

resource "random_password" "this" {
  for_each = { for k, v in var.secrets : k => v if v.generate_random }

  length           = 32
  special          = true
  override_special = "!#$%^&*()-_=+[]{}<>:?"
}

# Seeds an initial value so the secret isn't empty on first apply.
# Rotate/replace via AWS Secrets Manager rotation or manually after creation;
# Terraform will not overwrite the value on subsequent applies (lifecycle ignore_changes).
resource "aws_secretsmanager_secret_version" "this" {
  for_each = var.secrets

  secret_id     = aws_secretsmanager_secret.this[each.key].id
  secret_string = each.value.generate_random ? random_password.this[each.key].result : "CHANGE_ME_MANUALLY"

  lifecycle {
    ignore_changes = [secret_string]
  }
}

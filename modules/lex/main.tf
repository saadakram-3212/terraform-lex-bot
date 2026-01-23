# IAM Role for Lex Bot
resource "aws_iam_role" "lex_bot" {
  name        = var.iam_role_name != "" ? var.iam_role_name : "${var.bot_name}-role"
  description = "IAM role for Lex bot ${var.bot_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lexv2.amazonaws.com"
        }
      },
    ]
  })

  tags = merge(
    var.tags,
    {
      Name      = var.iam_role_name != "" ? var.iam_role_name : "${var.bot_name}-role"
      ManagedBy = "Terraform"
    }
  )
}

# IAM Policy for Lex Bot (optional - attach policies as needed)
resource "aws_iam_role_policy_attachment" "lex_bot_policy" {
  for_each = toset(var.iam_policy_arns)

  role       = aws_iam_role.lex_bot.name
  policy_arn = each.value
}

# Lex V2 Bot
resource "aws_lexv2models_bot" "this" {
  name        = var.bot_name
  description = var.bot_description

  data_privacy {
    child_directed = var.child_directed
  }

  idle_session_ttl_in_seconds = var.idle_session_ttl_in_seconds
  role_arn                    = aws_iam_role.lex_bot.arn
  type                        = var.bot_type

  tags = merge(
    var.tags,
    {
      Name      = var.bot_name
      ManagedBy = "Terraform"
    }
  )

  dynamic "members" {
    for_each = var.bot_members
    content {
      alias_id   = members.value.alias_id
      alias_name = members.value.alias_name
      id         = members.value.id
      name       = members.value.name
      version    = members.value.version
    }
  }
}

# Lex V2 Bot Locales
resource "aws_lexv2models_bot_locale" "this" {
  for_each = { for locale in var.bot_locales : locale.locale_id => locale }

  bot_id                           = aws_lexv2models_bot.this.id
  bot_version                      = each.value.bot_version
  locale_id                        = each.value.locale_id
  n_lu_intent_confidence_threshold = each.value.n_lu_intent_confidence_threshold
  description                      = each.value.description

  dynamic "voice_settings" {
    for_each = each.value.voice_settings != null ? [each.value.voice_settings] : []
    content {
      voice_id = voice_settings.value.voice_id
      engine   = voice_settings.value.engine
    }
  }

  timeouts {
    create = var.locale_timeouts.create
    update = var.locale_timeouts.update
    delete = var.locale_timeouts.delete
  }
}
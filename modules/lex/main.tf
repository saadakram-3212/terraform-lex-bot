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


# Lex V2 Bot Version
resource "aws_lexv2models_bot_version" "this" {
  for_each = { for version in var.bot_versions : version.version_name => version }

  bot_id      = aws_lexv2models_bot.this.id
  description = each.value.description

  locale_specification = {
    for locale_id, locale_config in each.value.locale_specification :
    locale_id => {
      source_bot_version = locale_config.source_bot_version
    }
  }

  depends_on = [aws_lexv2models_bot_locale.this]
}

# Lex V2 Bot Intents
resource "aws_lexv2models_intent" "this" {
  for_each = { for intent in var.bot_intents : intent.name => intent }

  bot_id      = aws_lexv2models_bot.this.id
  bot_version = each.value.bot_version
  locale_id   = each.value.locale_id
  name        = each.value.name
  description = each.value.description

  # Sample Utterances
  dynamic "sample_utterance" {
    for_each = each.value.sample_utterances
    content {
      utterance = sample_utterance.value
    }
  }

  # Dialog Code Hook
  dynamic "dialog_code_hook" {
    for_each = each.value.dialog_code_hook != null ? [each.value.dialog_code_hook] : []
    content {
      enabled = dialog_code_hook.value.enabled
    }
  }

  # Fulfillment Code Hook
  dynamic "fulfillment_code_hook" {
    for_each = each.value.fulfillment_code_hook != null ? [each.value.fulfillment_code_hook] : []
    content {
      enabled = fulfillment_code_hook.value.enabled
      active  = fulfillment_code_hook.value.active
      
      dynamic "post_fulfillment_status_specification" {
        for_each = fulfillment_code_hook.value.post_fulfillment_status_specification != null ? [fulfillment_code_hook.value.post_fulfillment_status_specification] : []
        content {
          dynamic "success_response" {
            for_each = post_fulfillment_status_specification.value.success_response != null ? [post_fulfillment_status_specification.value.success_response] : []
            content {
              allow_interrupt = success_response.value.allow_interrupt
              
              dynamic "message_group" {
                for_each = success_response.value.message_groups
                content {
                  message {
                    plain_text_message {
                      value = message_group.value.plain_text_message
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  # Confirmation Setting
  dynamic "confirmation_setting" {
    for_each = each.value.confirmation_setting != null ? [each.value.confirmation_setting] : []
    content {
      active = confirmation_setting.value.active

      prompt_specification {
        max_retries                = confirmation_setting.value.prompt_specification.max_retries
        allow_interrupt            = confirmation_setting.value.prompt_specification.allow_interrupt
        message_selection_strategy = confirmation_setting.value.prompt_specification.message_selection_strategy

        dynamic "message_group" {
          for_each = confirmation_setting.value.prompt_specification.message_groups
          content {
            message {
              plain_text_message {
                value = message_group.value.plain_text_message
              }
            }
          }
        }

        # Default prompt attempts specification to avoid AWS defaults causing drift
        dynamic "prompt_attempts_specification" {
          for_each = confirmation_setting.value.prompt_specification.prompt_attempts_specification
          content {
            allow_interrupt = prompt_attempts_specification.value.allow_interrupt
            map_block_key   = prompt_attempts_specification.value.map_block_key

            allowed_input_types {
              allow_audio_input = prompt_attempts_specification.value.allowed_input_types.allow_audio_input
              allow_dtmf_input  = prompt_attempts_specification.value.allowed_input_types.allow_dtmf_input
            }

            dynamic "audio_and_dtmf_input_specification" {
              for_each = prompt_attempts_specification.value.audio_and_dtmf_input_specification != null ? [prompt_attempts_specification.value.audio_and_dtmf_input_specification] : []
              content {
                start_timeout_ms = audio_and_dtmf_input_specification.value.start_timeout_ms

                audio_specification {
                  end_timeout_ms = audio_and_dtmf_input_specification.value.audio_specification.end_timeout_ms
                  max_length_ms  = audio_and_dtmf_input_specification.value.audio_specification.max_length_ms
                }

                dtmf_specification {
                  deletion_character = audio_and_dtmf_input_specification.value.dtmf_specification.deletion_character
                  end_character      = audio_and_dtmf_input_specification.value.dtmf_specification.end_character
                  end_timeout_ms     = audio_and_dtmf_input_specification.value.dtmf_specification.end_timeout_ms
                  max_length         = audio_and_dtmf_input_specification.value.dtmf_specification.max_length
                }
              }
            }

            dynamic "text_input_specification" {
              for_each = prompt_attempts_specification.value.text_input_specification != null ? [prompt_attempts_specification.value.text_input_specification] : []
              content {
                start_timeout_ms = text_input_specification.value.start_timeout_ms
              }
            }
          }
        }
      }

      # Declination Response
      dynamic "declination_response" {
        for_each = confirmation_setting.value.declination_response != null ? [confirmation_setting.value.declination_response] : []
        content {
          allow_interrupt = declination_response.value.allow_interrupt

          dynamic "message_group" {
            for_each = declination_response.value.message_groups
            content {
              message {
                plain_text_message {
                  value = message_group.value.plain_text_message
                }
              }
            }
          }
        }
      }
    }
  }

  # Closing Setting
  dynamic "closing_setting" {
    for_each = each.value.closing_setting != null ? [each.value.closing_setting] : []
    content {
      active = closing_setting.value.active

      dynamic "closing_response" {
        for_each = closing_setting.value.closing_response != null ? [closing_setting.value.closing_response] : []
        content {
          allow_interrupt = closing_response.value.allow_interrupt

          dynamic "message_group" {
            for_each = closing_response.value.message_groups
            content {
              message {
                plain_text_message {
                  value = message_group.value.plain_text_message
                }
              }
            }
          }
        }
      }
    }
  }

  # Input Contexts
  dynamic "input_context" {
    for_each = each.value.input_contexts
    content {
      name = input_context.value
    }
  }

  # Output Contexts
  dynamic "output_context" {
    for_each = each.value.output_contexts
    content {
      name                   = output_context.value.name
      time_to_live_in_seconds = output_context.value.time_to_live_in_seconds
      turns_to_live          = output_context.value.turns_to_live
    }
  }

  # Kendra Configuration
  dynamic "kendra_configuration" {
    for_each = each.value.kendra_configuration != null ? [each.value.kendra_configuration] : []
    content {
      kendra_index                 = kendra_configuration.value.kendra_index
      query_filter_string          = kendra_configuration.value.query_filter_string
      query_filter_string_enabled  = kendra_configuration.value.query_filter_string_enabled
    }
  }

  parent_intent_signature = each.value.parent_intent_signature

  timeouts {
    create = var.intent_timeouts.create
    update = var.intent_timeouts.update
    delete = var.intent_timeouts.delete
  }

  depends_on = [aws_lexv2models_bot_locale.this]
}
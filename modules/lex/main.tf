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

# Lex V2 Slot
resource "aws_lexv2models_slot" "this" {
  for_each = {
    for slot in var.bot_slots : 
    "${slot.intent_name}.${slot.locale_id}.${slot.name}" => slot
  }

  bot_id      = aws_lexv2models_bot.this.id
  bot_version = each.value.bot_version
  intent_id   = aws_lexv2models_intent.this[each.value.intent_name].intent_id
  locale_id   = each.value.locale_id
  name        = each.value.name
  
  description  = each.value.description
  slot_type_id = each.value.slot_type_id

  # Multiple values setting
  dynamic "multiple_values_setting" {
    for_each = each.value.allow_multiple_values ? [1] : []
    content {
      allow_multiple_values = each.value.allow_multiple_values
    }
  }

  # Obfuscation setting
  dynamic "obfuscation_setting" {
    for_each = each.value.obfuscation_setting != null ? [each.value.obfuscation_setting] : []
    content {
      obfuscation_setting_type = obfuscation_setting.value.obfuscation_setting_type
    }
  }

  # Value elicitation setting (Required)
  value_elicitation_setting {
    slot_constraint = each.value.value_elicitation_setting.slot_constraint

    # Default value specification
    dynamic "default_value_specification" {
      for_each = each.value.value_elicitation_setting.default_value_specification != null ? [each.value.value_elicitation_setting.default_value_specification] : []
      content {
        dynamic "default_value_list" {
          for_each = default_value_specification.value.default_value_list
          content {
            default_value = default_value_list.value.default_value
          }
        }
      }
    }

    # Prompt specification
    dynamic "prompt_specification" {
      for_each = each.value.value_elicitation_setting.prompt_specification != null ? [each.value.value_elicitation_setting.prompt_specification] : []
      content {
        allow_interrupt            = prompt_specification.value.allow_interrupt
        max_retries                = prompt_specification.value.max_retries
        message_selection_strategy = prompt_specification.value.message_selection_strategy

        dynamic "message_group" {
          for_each = prompt_specification.value.message_groups
          content {
            message {
              plain_text_message {
                value = message_group.value.plain_text_message
              }
            }
          }
        }

        # Prompt attempts specification
        dynamic "prompt_attempts_specification" {
          for_each = prompt_specification.value.prompt_attempts_specification != null ? prompt_specification.value.prompt_attempts_specification : []
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
    }

    # Sample utterances
    dynamic "sample_utterance" {
      for_each = each.value.value_elicitation_setting.sample_utterances != null ? each.value.value_elicitation_setting.sample_utterances : []
      content {
        utterance = sample_utterance.value.utterance
      }
    }

    # Slot resolution setting
    dynamic "slot_resolution_setting" {
      for_each = each.value.value_elicitation_setting.slot_resolution_setting != null ? [each.value.value_elicitation_setting.slot_resolution_setting] : []
      content {
        slot_resolution_strategy = slot_resolution_setting.value.slot_resolution_strategy
      }
    }

    # Wait and continue specification
    dynamic "wait_and_continue_specification" {
      for_each = each.value.value_elicitation_setting.wait_and_continue_specification != null ? [each.value.value_elicitation_setting.wait_and_continue_specification] : []
      content {
        active = wait_and_continue_specification.value.active

        # Continue response
        continue_response {
          allow_interrupt = wait_and_continue_specification.value.continue_response.allow_interrupt

          dynamic "message_group" {
            for_each = wait_and_continue_specification.value.continue_response.message_groups
            content {
              message {
                plain_text_message {
                  value = message_group.value.plain_text_message
                }
              }
            }
          }
        }

        # Waiting response
        waiting_response {
          allow_interrupt = wait_and_continue_specification.value.waiting_response.allow_interrupt

          dynamic "message_group" {
            for_each = wait_and_continue_specification.value.waiting_response.message_groups
            content {
              message {
                plain_text_message {
                  value = message_group.value.plain_text_message
                }
              }
            }
          }
        }

        # Still waiting response
        dynamic "still_waiting_response" {
          for_each = wait_and_continue_specification.value.still_waiting_response != null ? [wait_and_continue_specification.value.still_waiting_response] : []
          content {
            frequency_in_seconds = still_waiting_response.value.frequency_in_seconds
            timeout_in_seconds   = still_waiting_response.value.timeout_in_seconds
            allow_interrupt      = still_waiting_response.value.allow_interrupt

            dynamic "message_group" {
              for_each = still_waiting_response.value.message_groups
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

  # Sub-slot setting
  dynamic "sub_slot_setting" {
    for_each = each.value.sub_slot_setting != null ? [each.value.sub_slot_setting] : []
    content {
      expression = sub_slot_setting.value.expression

      dynamic "slot_specification" {
        for_each = sub_slot_setting.value.slot_specification != null ? sub_slot_setting.value.slot_specification : {}
        iterator = spec
        content {
          slot_type_id = spec.value.slot_type_id
          map_block_key = spec.key

          value_elicitation_setting {            
            # Include default value specification if provided
            dynamic "default_value_specification" {
              for_each = try(spec.value.value_elicitation_setting.default_value_specification != null ? [spec.value.value_elicitation_setting.default_value_specification] : [], [])
              content {
                dynamic "default_value_list" {
                  for_each = default_value_specification.value.default_value_list
                  content {
                    default_value = default_value_list.value.default_value
                  }
                }
              }
            }
            
            # Include prompt specification if provided
            dynamic "prompt_specification" {
              for_each = try(spec.value.value_elicitation_setting.prompt_specification != null ? [spec.value.value_elicitation_setting.prompt_specification] : [], [])
              content {
                allow_interrupt            = prompt_specification.value.allow_interrupt
                max_retries                = prompt_specification.value.max_retries
                message_selection_strategy = prompt_specification.value.message_selection_strategy

                dynamic "message_group" {
                  for_each = prompt_specification.value.message_groups
                  content {
                    message {
                      plain_text_message {
                        value = message_group.value.plain_text_message
                      }
                    }
                  }
                }
                
                # Include prompt attempts specification if provided
                dynamic "prompt_attempts_specification" {
                  for_each = try(prompt_specification.value.prompt_attempts_specification != null ? prompt_specification.value.prompt_attempts_specification : [], [])
                  content {
                    allow_interrupt = prompt_attempts_specification.value.allow_interrupt
                    map_block_key   = prompt_attempts_specification.value.map_block_key
                    
                    allowed_input_types {
                      allow_audio_input = prompt_attempts_specification.value.allowed_input_types.allow_audio_input
                      allow_dtmf_input  = prompt_attempts_specification.value.allowed_input_types.allow_dtmf_input
                    }
                    
                    # Include audio and dtmf input specification if provided
                    dynamic "audio_and_dtmf_input_specification" {
                      for_each = try(prompt_attempts_specification.value.audio_and_dtmf_input_specification != null ? [prompt_attempts_specification.value.audio_and_dtmf_input_specification] : [], [])
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
                    
                    # Include text input specification if provided
                    dynamic "text_input_specification" {
                      for_each = try(prompt_attempts_specification.value.text_input_specification != null ? [prompt_attempts_specification.value.text_input_specification] : [], [])
                      content {
                        start_timeout_ms = text_input_specification.value.start_timeout_ms
                      }
                    }
                  }
                }
              }
            }
            
            # Include sample utterances if provided
            dynamic "sample_utterance" {
              for_each = try(spec.value.value_elicitation_setting.sample_utterances != null ? spec.value.value_elicitation_setting.sample_utterances : [], [])
              content {
                utterance = sample_utterance.value.utterance
              }
            }
            
            # Include slot resolution setting if provided
            #dynamic "slot_resolution_setting" {
              #for_each = try(spec.value.value_elicitation_setting.slot_resolution_setting != null ? [spec.value.value_elicitation_setting.slot_resolution_setting] : [], [])
              #content {
                #slot_resolution_strategy = slot_resolution_setting.value.slot_resolution_strategy
              #}
            #}
            
            # Include wait and continue specification if provided
            dynamic "wait_and_continue_specification" {
              for_each = try(spec.value.value_elicitation_setting.wait_and_continue_specification != null ? [spec.value.value_elicitation_setting.wait_and_continue_specification] : [], [])
              content {
                active = wait_and_continue_specification.value.active

                # Continue response
                continue_response {
                  allow_interrupt = wait_and_continue_specification.value.continue_response.allow_interrupt

                  dynamic "message_group" {
                    for_each = wait_and_continue_specification.value.continue_response.message_groups
                    content {
                      message {
                        plain_text_message {
                          value = message_group.value.plain_text_message
                        }
                      }
                    }
                  }
                }

                # Waiting response
                waiting_response {
                  allow_interrupt = wait_and_continue_specification.value.waiting_response.allow_interrupt

                  dynamic "message_group" {
                    for_each = wait_and_continue_specification.value.waiting_response.message_groups
                    content {
                      message {
                        plain_text_message {
                          value = message_group.value.plain_text_message
                        }
                      }
                    }
                  }
                }

                # Still waiting response if provided
                dynamic "still_waiting_response" {
                  for_each = try(wait_and_continue_specification.value.still_waiting_response != null ? [wait_and_continue_specification.value.still_waiting_response] : [], [])
                  content {
                    frequency_in_seconds = still_waiting_response.value.frequency_in_seconds
                    timeout_in_seconds   = still_waiting_response.value.timeout_in_seconds
                    allow_interrupt      = still_waiting_response.value.allow_interrupt

                    dynamic "message_group" {
                      for_each = still_waiting_response.value.message_groups
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
      }
    }
  }

  timeouts {
    create = var.slot_timeouts.create
    update = var.slot_timeouts.update
    delete = var.slot_timeouts.delete
  }

  depends_on = [
    aws_lexv2models_bot_locale.this,
    aws_lexv2models_intent.this
  ]
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

  depends_on = [
    aws_lexv2models_bot_locale.this,
    aws_lexv2models_intent.this,
    aws_lexv2models_slot.this
  ]
}
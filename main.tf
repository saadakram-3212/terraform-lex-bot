# Create multiple Lex bots using for_each
module "lex_bot" {
  for_each = var.lex_bots

  source = "./modules/lex"

  
  bot_name                    = each.value.bot_name
  bot_description             = each.value.bot_description
  child_directed              = each.value.child_directed
  idle_session_ttl_in_seconds = each.value.idle_session_ttl_in_seconds
  bot_type                    = each.value.bot_type
  role_arn                    = aws_iam_role.lexv2_service_role.arn

  # Bot alias configuration
  create_bot_alias = each.value.create_bot_alias
  bot_alias_name = each.value.bot_alias_name
  bot_alias_version = each.value.bot_alias_version
  bot_alias_description = each.value.bot_alias_description
  enable_conversation_logs = each.value.enable_conversation_logs
  conversation_log_settings = each.value.conversation_log_settings
  alias_tags = each.value.alias_tags
  

  # Connect Integration
  integrate_to_connect = each.value.integrate_to_connect
  connect_instance_id  = each.value.connect_instance_id

  # Bot members
  bot_members = each.value.bot_members

  # Locales
  bot_locales     = each.value.bot_locales
  locale_timeouts = each.value.locale_timeouts

  tags = merge(each.value.tags, {
    BotName = each.value.bot_name
  })

  # Intents
  bot_intents     = each.value.bot_intents
  intent_timeouts = each.value.intent_timeouts

  # Slots
  bot_slots     = each.value.bot_slots
  slot_timeouts = each.value.slot_timeouts

  # Slot Types
  bot_slot_types     = each.value.bot_slot_types
  slot_type_timeouts = each.value.slot_type_timeouts
  # Knowledge Base Intents
  knowledge_base_intent_enabled = each.value.knowledge_base_intent_enabled
  knowledge_base_intents = each.value.knowledge_base_intents
}

resource "aws_iam_role" "lexv2_service_role" {
  name = "lexv2-service-role-test"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "LexV2AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lexv2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "bedrock_full_access" {
  role       = aws_iam_role.lexv2_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonBedrockFullAccess"
}

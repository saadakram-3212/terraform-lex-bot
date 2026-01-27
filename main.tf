# Create multiple Lex bots using for_each
module "lex_bot" {
  for_each = var.lex_bots
  
  source = "./modules/lex"

  # Basic bot configuration
  bot_name                    = each.value.bot_name
  bot_description             = each.value.bot_description
  child_directed              = each.value.child_directed
  idle_session_ttl_in_seconds = each.value.idle_session_ttl_in_seconds
  bot_type                    = each.value.bot_type
  
  # IAM Configuration
  iam_role_name   = each.value.iam_role_name
  iam_policy_arns = each.value.iam_policy_arns
  
  # Bot members
  bot_members = each.value.bot_members
  
  # Locales
  bot_locales     = each.value.bot_locales
  locale_timeouts = each.value.locale_timeouts
  
  # Tags (merge global tags with bot-specific tags)
  tags = merge(var.global_tags, each.value.tags, {
    BotName = each.value.bot_name
  })
  
  # Bot Versions
  bot_versions = each.value.bot_versions
  
  # Intents
  bot_intents     = each.value.bot_intents
  intent_timeouts = each.value.intent_timeouts
  
  # Slots
  bot_slots     = each.value.bot_slots
  slot_timeouts = each.value.slot_timeouts
  
  # Slot Types
  bot_slot_types     = each.value.bot_slot_types
  slot_type_timeouts = each.value.slot_type_timeouts
}
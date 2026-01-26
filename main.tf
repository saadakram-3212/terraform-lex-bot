# Call the Lex Bot module
module "lex_bot" {
  source = "./modules/lex"

  bot_name                    = var.bot_name
  bot_description             = var.bot_description
  child_directed              = var.child_directed
  idle_session_ttl_in_seconds = var.idle_session_ttl_in_seconds
  bot_type                    = var.bot_type
  iam_role_name               = var.iam_role_name
  iam_policy_arns             = var.iam_policy_arns
  bot_members                 = var.bot_members
  bot_locales                 = var.bot_locales
  locale_timeouts             = var.locale_timeouts
  tags                        = var.tags
  bot_versions                = var.bot_versions
  bot_intents                 = var.bot_intents
  intent_timeouts             = var.intent_timeouts
  bot_slots                   = var.bot_slots
  slot_timeouts               = var.slot_timeouts
}
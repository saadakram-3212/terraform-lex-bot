# Output all bot IDs
output "lex_bot_id" {
  description = "Map of bot names to their IDs"
  value = {
    for key, bot in module.lex_bot :
    key => bot.bot_id
  }
}

output "lex_bot_arn" {
  description = "Map of bot names to their ARNs"
  value = {
    for key, bot in module.lex_bot :
    key => bot.bot_arn
  }
}

output "lex_bot_name" {
  description = "Map of bot names"
  value = {
    for key, bot in module.lex_bot :
    key => bot.bot_name
  }
}

output "lex_bot_iam_role_arn" {
  description = "Map of bot names to their IAM role ARNs"
  value = {
    for key, bot in module.lex_bot :
    key => bot.iam_role_arn
  }
}

output "lex_bot_iam_role_name" {
  description = "Map of bot names to their IAM role names"
  value = {
    for key, bot in module.lex_bot :
    key => bot.iam_role_name
  }
}

output "lex_bot_locales" {
  description = "Map of bot names to their locales"
  value = {
    for key, bot in module.lex_bot :
    key => bot.bot_locales
  }
}

output "lex_bot_locale_ids" {
  description = "Map of bot names to their locale IDs"
  value = {
    for key, bot in module.lex_bot :
    key => bot.bot_locale_ids
  }
}

output "lex_bot_locale_names" {
  description = "Map of bot locale IDs to their names"
  value = {
    for key, bot in module.lex_bot :
    key => bot.bot_locale_names
  }
}

output "lex_bot_versions" {
  description = "Map of bot names to their versions"
  value = {
    for key, bot in module.lex_bot :
    key => bot.bot_versions
  }
}

output "lex_bot_version_ids" {
  description = "Map of bot names and versions to their IDs"
  value = {
    for key, bot in module.lex_bot :
    key => bot.bot_version_ids
  }
}

output "lex_bot_version_numbers" {
  description = "Map of bot version IDs to their version numbers"
  value = {
    for key, bot in module.lex_bot :
    key => bot.bot_version_numbers
  }
}

output "lex_bot_intents" {
  description = "Map of bot names to their intents"
  value = {
    for key, bot in module.lex_bot :
    key => bot.bot_intents
  }
}

output "lex_bot_intent_ids" {
  description = "Map of bot intent names to their IDs"
  value = {
    for key, bot in module.lex_bot :
    key => bot.bot_intent_ids
  }
}

output "lex_bot_intent_full_ids" {
  description = "Map of bot intent IDs to their full resource IDs"
  value = {
    for key, bot in module.lex_bot :
    key => bot.bot_intent_full_ids
  }
}

# output "lex_bot_slot_ids" {
#   description = "Map of bot names to their slot IDs"
#   value = {
#     for key, bot in module.lex_bot :
#     key => bot.slot_ids
#   }
# }

# output "lex_bot_slot_type_ids" {
#   description = "Map of bot names to their slot type IDs"
#   value = {
#     for key, bot in module.lex_bot :
#     key => bot.slot_type_ids
#   }
# }

output "simple_faq_bot_id" {
  description = "ID of the simple FAQ bot"
  value       = module.lex_bot["simple_faq_bot"].bot_id
}

output "simple_faq_bot_arn" {
  description = "ARN of the simple FAQ bot"
  value       = module.lex_bot["simple_faq_bot"].bot_arn
}

output "simple_faq_bot_name" {
  description = "Name of the simple FAQ bot"
  value       = module.lex_bot["simple_faq_bot"].bot_name
}
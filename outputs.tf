output "lex_bot_id" {
  description = "ID of the Lex bot"
  value       = module.lex_bot.bot_id
}

output "lex_bot_arn" {
  description = "ARN of the Lex bot"
  value       = module.lex_bot.bot_arn
}

output "lex_bot_name" {
  description = "Name of the Lex bot"
  value       = module.lex_bot.bot_name
}

output "lex_bot_iam_role_arn" {
  description = "ARN of the IAM role for the Lex bot"
  value       = module.lex_bot.iam_role_arn
}

output "lex_bot_iam_role_name" {
  description = "Name of the IAM role for the Lex bot"
  value       = module.lex_bot.iam_role_name
}

output "lex_bot_locales" {
  description = "Bot locales information"
  value       = module.lex_bot.bot_locales
}

output "lex_bot_locale_ids" {
  description = "List of bot locale IDs"
  value       = module.lex_bot.bot_locale_ids
}

output "lex_bot_locale_names" {
  description = "Map of locale IDs to their names"
  value       = module.lex_bot.bot_locale_names
}

output "lex_bot_versions" {
  description = "Bot versions information"
  value       = module.lex_bot.bot_versions
}

output "lex_bot_version_ids" {
  description = "List of bot version IDs"
  value       = module.lex_bot.bot_version_ids
}

output "lex_bot_version_numbers" {
  description = "Map of version names to version numbers"
  value       = module.lex_bot.bot_version_numbers
}
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
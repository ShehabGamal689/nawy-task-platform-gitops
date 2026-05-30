resource "aws_secretsmanager_secret" "gitops_vault" {
  name                    = "gitops-secrets-vault"
  recovery_window_in_days = 0 
}

resource "aws_secretsmanager_secret_version" "gitops_vault_version" {
  secret_id     = aws_secretsmanager_secret.gitops_vault.id
 
  secret_string = jsonencode({
    github_token      = var.github_token
    REGISTRAR_API_KEY = var.registrar_api_key
    newrelic_key      = var.newrelic_key
  })
}

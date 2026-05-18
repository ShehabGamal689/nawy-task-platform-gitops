variable "github_token" {
  description = "GitHub PAT for ArgoCD and GHCR"
  type        = string
  sensitive   = true
}

resource "aws_secretsmanager_secret" "git_credentials" {
  name = "gitops-secrets-vault"
  recovery_window_in_days = 0 
}

resource "aws_secretsmanager_secret_version" "git_credentials_version" {
  secret_id     = aws_secretsmanager_secret.git_credentials.id
  secret_string = var.github_token
}

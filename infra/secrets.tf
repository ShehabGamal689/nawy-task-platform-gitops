variable "github_token" {
  description = "GitHub PAT for ArgoCD and GHCR"
  type        = string
  sensitive   = true
}

resource "aws_secretsmanager_secret" "git_credentials" {
  name = "gitops-secrets-vault"
  # CRITICAL FOR LABS: Forces instant deletion so you don't get errors tomorrow
  recovery_window_in_days = 0 
}

resource "aws_secretsmanager_secret_version" "git_credentials_version" {
  secret_id     = aws_secretsmanager_secret.git_credentials.id
  secret_string = var.github_token
}

resource "kubernetes_secret" "github_token" {
  metadata {
    name      = "github-token"
    namespace = "argocd"
  }

  data = {
    username = "ShehabGamal689"
    # Pulling securely from the AWS Secret Version
    password = aws_secretsmanager_secret_version.git_credentials_version.secret_string 
  }

  type = "Opaque"
}

resource "kubernetes_secret" "ghcr_login" {
  metadata {
    name      = "ghcr-login"
    namespace = "nawy-app"
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "ghcr.io" = {
          # Pulling securely from AWS and encoding it
          auth = base64encode("ShehabGamal689:${aws_secretsmanager_secret_version.git_credentials_version.secret_string}")
        }
      }
    })
  }
}

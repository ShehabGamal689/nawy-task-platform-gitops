variable "github_token" {
  description = "GitHub PAT for ArgoCD and GHCR"
  type        = string
  sensitive   = true
}
variable "registrar_api_key" {
  description = "API Key for your domain registrar to automate NS updates"
  type        = string
  sensitive   = true
}

variable "newrelic_key" {
  description = "New Relic License Key for APM and Cluster monitoring"
  type        = string
  sensitive   = true
}

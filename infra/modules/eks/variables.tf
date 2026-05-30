variable "cluster_name" { type = string }
variable "vpc_id" { type = string }
variable "public_subnet_ids" { type = list(string) }
variable "private_subnet_ids" { type = list(string) }
variable "registrar_api_key" {
  description = "API Key for your domain registrar to automate NS updates"
  type        = string
  sensitive   = true
}

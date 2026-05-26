output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "aws_region" {
  description = "AWS region"
  value       = "us-east-1"
}

output "oidc_provider_url" {
  description = "The OIDC Provider URL for IRSA"
  value       = module.eks.oidc_provider_url
}

output "route53_name_servers" {
  value = module.eks.name_servers
}

output "external_dns_role_arn" { 
  value = module.eks.external_dns_role_arn 
}

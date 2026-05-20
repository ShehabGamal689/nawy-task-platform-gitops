output "cluster_name" { value = aws_eks_cluster.this.name }
output "cluster_endpoint" { value = aws_eks_cluster.this.endpoint }
output "oidc_provider_url" { value = aws_iam_openid_connect_provider.eks.url }
output "cluster_ca_certificate" { value = aws_eks_cluster.this.certificate_authority[0].data }
output "certificate_arn" {value = aws_acm_certificate.cert.arn}

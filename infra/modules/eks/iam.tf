resource "aws_iam_policy" "external_dns" {
  name        = "${var.cluster_name}-external-dns-policy"
  description = "Allows ExternalDNS to manage Route 53 records"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "route53:ChangeResourceRecordSets"
        ],
        Resource = ["arn:aws:route53:::hostedzone/*"]
      },
      {
        Effect = "Allow",
        Action = [
          "route53:ListHostedZones",
          "route53:ListResourceRecordSets",
          "route53:ListTagsForResource"
        ],
        Resource = ["*"]
      }
    ]
  })
}

data "aws_iam_openid_connect_provider" "oidc_provider" {
  url = aws_eks_cluster.this.identity[0].oidc[0].issuer
  depends_on = [aws_iam_openid_connect_provider.eks]
}


resource "aws_iam_role" "external_dns" {
  name = "${var.cluster_name}-external-dns-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Federated = data.aws_iam_openid_connect_provider.oidc_provider.arn
      },
      Action = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        "StringEquals" = {
          "${replace(data.aws_iam_openid_connect_provider.oidc_provider.url, "https://", "")}:sub" : "system:serviceaccount:kube-system:external-dns",
          "${replace(data.aws_iam_openid_connect_provider.oidc_provider.url, "https://", "")}:aud" : "sts.amazonaws.com"
        }
      }
    }]
  })
}


resource "kubernetes_service_account_v1" "external_dns" {
  metadata {
    name      = "external-dns"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.external_dns.arn 
    }
  }
  depends_on = [aws_eks_cluster.this] 
}


resource "aws_iam_role_policy_attachment" "external_dns" {
  role       = aws_iam_role.external_dns.name
  policy_arn = aws_iam_policy.external_dns.arn
}

output "external_dns_role_arn" {
  value = aws_iam_role.external_dns.arn
}


resource "aws_iam_policy" "external_secrets" {
  name        = "${var.cluster_name}-external-secrets-policy"
  description = "Allows ESO to read secrets from AWS Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = ["arn:aws:secretsmanager:us-east-1:*:secret:gitops-secrets-vault-*"]
      }
    ]
  })
}


resource "aws_iam_role" "external_secrets" {
  name = "${var.cluster_name}-external-secrets-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = data.aws_iam_openid_connect_provider.oidc_provider.arn }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        "StringEquals" = {
          "${replace(data.aws_iam_openid_connect_provider.oidc_provider.url, "https://", "")}:sub" : "system:serviceaccount:external-secrets:external-secrets-sa",
          "${replace(data.aws_iam_openid_connect_provider.oidc_provider.url, "https://", "")}:aud" : "sts.amazonaws.com"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "external_secrets" {
  role       = aws_iam_role.external_secrets.name
  policy_arn = aws_iam_policy.external_secrets.arn
}


resource "kubernetes_namespace_v1" "external_secrets" {
  metadata { name = "external-secrets" }
}

resource "kubernetes_service_account_v1" "external_secrets" {
  metadata {
    name      = "external-secrets-sa"
    namespace = kubernetes_namespace_v1.external_secrets.metadata[0].name
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.external_secrets.arn
    }
  }
}

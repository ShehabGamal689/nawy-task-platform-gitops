#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "🚀 Starting Nawy Task Automated Deployment..."
echo "================================================="

# 1. Securely ask for the GitHub Token (so it doesn't save in your bash history)
read -sp "Enter your GitHub Personal Access Token (ghp_...): " GITHUB_TOKEN
echo ""
echo "✅ Token received."

# 2. Provision Infrastructure (EKS + Secrets)
echo "🏗️  Step 1: Provisioning AWS EKS and Secrets via Terraform..."
cd infra
terraform init
# We pass the token securely to Terraform in memory
terraform apply -var="github_token=$GITHUB_TOKEN" -auto-approve
echo "✅ Infrastructure provisioned successfully."

# 3. Update Local Kubeconfig
echo "🔌 Step 2: Connecting to the new EKS cluster..."
# NOTE: Replace 'your-region' and 'your-cluster-name' with your actual AWS region and cluster name!
# Example: aws eks update-kubeconfig --region us-east-1 --name nawy-cluster
aws eks update-kubeconfig --region us-east-1 --name nawy-cluster 
echo "✅ Cluster connected."

# 4. Run Ansible Configuration (e.g., Installing ArgoCD, NGINX, etc.)
echo "⚙️  Step 3: Running Ansible Playbooks..."
cd ../ansible
# Run your playbook (update 'playbook.yml' to whatever your actual file is named)
ansible-playbook playbook.yml
echo "✅ Ansible configuration complete."

echo "================================================="
echo "🎉 DEPLOYMENT COMPLETE! 🎉"
echo "Your GitOps loop is now active. Argo CD is taking over!"
echo ""
echo "Run 'kubectl get pods -A' to watch your environment spin up."

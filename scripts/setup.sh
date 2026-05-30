#!/bin/bash

set -e

echo "Starting Nawy Task Automated Deployment..."
echo "================================================="

if [ -f "venv/bin/activate" ]; then
    source venv/bin/activate
fi

read -p "Enter your S3 Bucket Name for Terraform State: " S3_BUCKET
read -p "Enter your GitHub Username: " GITHUB_USERNAME
read -p "Enter your GitHub Personal Access Token: " GITHUB_TOKEN
echo ""
read -p "Enter your New Relic License Key: " NR_LICENSE_KEY
echo ""
read -p "Enter your Domain Registrar API Key: " REGISTRAR_API_KEY
echo ""
echo -e "\n Credentials received."
echo "================================================="
export TF_VAR_registrar_api_key=$REGISTRAR_API_KEY
export TF_VAR_github_token=$GITHUB_TOKEN
export TF_VAR_newrelic_key=$NR_LICENSE_KEY


echo "Step 1: Terraform Apply..."
cd infra

terraform init -backend-config="bucket=$S3_BUCKET" -upgrade -reconfigure

terraform apply -auto-approve

CLUSTER_NAME=$(terraform output -raw cluster_name)
AWS_REGION=$(terraform output -raw aws_region)
cd ..

echo "================================================="


echo "Step 2: Connecting to EKS Cluster ($CLUSTER_NAME)..."
aws eks update-kubeconfig --region $AWS_REGION --name $CLUSTER_NAME

echo "================================================="

echo "Step 3: Running Ansible Bootstrapping..."
cd ansible

ansible-playbook install-argocd.yaml

echo "================================================="
echo " DEPLOYMENT COMPLETE!"


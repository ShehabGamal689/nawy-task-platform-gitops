#!/bin/bash

set -e

echo "Starting Nawy Task Automated Deployment..."
echo "================================================="

if [ -f "venv/bin/activate" ]; then
    source venv/bin/activate
fi

read -p "Enter your S3 Bucket Name for Terraform State: " S3_BUCKET
read -p "Enter your GitHub Username: " GITHUB_USERNAME
read -sp "Enter your GitHub Personal Access Token: " GITHUB_TOKEN
echo ""
read -sp "Enter your New Relic License Key: " NR_LICENSE_KEY
echo -e "\n Credentials received."
echo "================================================="

echo "Step 1: Terraform Apply..."
cd infra

terraform init -backend-config="bucket=$S3_BUCKET" -upgrade -reconfigure

terraform apply -var="github_token=$GITHUB_TOKEN" -auto-approve

CLUSTER_NAME=$(terraform output -raw cluster_name)
AWS_REGION=$(terraform output -raw aws_region)
cd ..

echo "================================================="


echo "Step 2: Connecting to EKS Cluster ($CLUSTER_NAME)..."
aws eks update-kubeconfig --region $AWS_REGION --name $CLUSTER_NAME

echo "================================================="

echo "Step 3: Kubernetes Secrets Setup..."

kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace nawy-app --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace newrelic --dry-run=client -o yaml | kubectl apply -f -

echo "Fetching GitHub token from AWS Secrets Manager..."
FETCHED_TOKEN=$(aws secretsmanager get-secret-value --secret-id gitops-secrets-vault --query SecretString --output text --region $AWS_REGION)

kubectl create secret generic github-token --from-literal=username=$GITHUB_USERNAME --from-literal=password=$FETCHED_TOKEN -n argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl create secret docker-registry ghcr-login --docker-server=ghcr.io --docker-username=ShehabGamal689 --docker-password=$FETCHED_TOKEN -n nawy-app --dry-run=client -o yaml | kubectl apply -f -

echo "Injecting New Relic Secrets..."
kubectl create secret generic newrelic-key --from-literal=licenseKey=$NR_LICENSE_KEY -n newrelic --dry-run=client -o yaml | kubectl apply -f -
kubectl create secret generic newrelic-apm-key --from-literal=NEW_RELIC_LICENSE_KEY=$NR_LICENSE_KEY -n nawy-app --dry-run=client -o yaml | kubectl apply -f -

echo "Secrets successfully injected into the cluster."
echo "================================================="


echo "Step 4: Running Ansible Bootstrapping..."
cd ansible

ansible-playbook install-argocd.yaml

echo "================================================="
echo " DEPLOYMENT COMPLETE!"
echo "To check Argo CD pod status, run: kubectl get pods -n argocd"

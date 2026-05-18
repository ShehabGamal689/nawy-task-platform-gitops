# Nawy Task - Automated EKS GitOps Platform

This repository contains an end-to-end automated deployment of an AWS EKS cluster, configured with a GitOps CI/CD pipeline using Argo CD, and integrated with New Relic for infrastructure monitoring and alerting.

## 📑 Table of Contents
1. [Architecture Overview](#-architecture-overview)
2. [Prerequisites](#-prerequisites)
3. [Setup and Execution](#-setup-and-execution)
4. [CI/CD Pipeline (GitOps)](#-cicd-pipeline-gitops)
5. [Monitoring and Alerts](#-monitoring-and-alerts)
6. [Assumptions Made](#-assumptions-made)
7. [Cleanup](#-cleanup)

---

## 🏗️ Architecture Overview
This project separates infrastructure, configuration, and application deployment into distinct, automated layers:
* **Infrastructure as Code (Terraform):** Provisions the VPC, Subnets, EKS Cluster, and an AWS Secrets Manager vault to securely store GitHub credentials.
* **Configuration Management (Ansible):** Connects to the local Kubernetes context to bootstrap Argo CD, Image Updater, and necessary system namespaces.
* **GitOps (Argo CD):** Automates application deployment, synchronizing state directly from this Git repository.
* **Monitoring (New Relic):** Tracks Kubernetes metrics and triggers email alerts on critical events (e.g., Pod CrashLoops).

> `[Insert Screenshot: Architecture Diagram]`

---

## 📋 Prerequisites
Before running the automated setup, ensure the following tools are installed and configured on your local machine:

1. **AWS CLI:** Configured with an IAM user possessing administrator privileges (`aws configure`).
2. **Terraform:** v1.0+ installed.
3. **Ansible:** Core installed.
4. **Kubectl:** Installed and matching the EKS cluster version.
5. **AWS S3 Bucket:** An existing S3 bucket in your AWS account to store the Terraform remote state.
6. **GitHub Personal Access Token (PAT):** A token with `repo` and `read:packages`/`write:packages` permissions.

### 📝 Important: Forking the Repository
Because this is a GitOps project, Argo CD and GitHub Actions need to read/write to the repository they are deployed from. 

**Before running the script:**
1. **Fork** this repository to your own GitHub account.
2. Clone your forked repository to your local machine.
3. Do a global search and replace in the codebase: replace `ShehabGamal689` with `YOUR_GITHUB_USERNAME`.
   * *Specifically check `manifests/root-app.yaml` and `manifests/charts/nawy-app/values.yaml`.*
4. Ensure GitHub Actions are enabled in your forked repo settings so the image can be built and pushed to your GHCR.

---

## 🚀 Setup and Execution

To deploy the entire stack from scratch, follow these steps:

### 1. Clone your Forked Repository
```bash
git clone [https://github.com/YOUR_USERNAME/nawy-task-platform-gitops.git](https://github.com/YOUR_USERNAME/nawy-task-platform-gitops.git)
cd nawy-task-platform-gitops

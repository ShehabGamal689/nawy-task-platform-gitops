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
Make sure to replace `YOUR_USERNAME` with your actual GitHub username where you forked the repository.
```bash
git clone [https://github.com/YOUR_USERNAME/nawy-task-platform-gitops.git](https://github.com/YOUR_USERNAME/nawy-task-platform-gitops.git)
cd nawy-task-platform-gitops
```

### 2. Run the Automation Script
Execute the master deployment script. This script handles Terraform initialization, cluster creation, `kubeconfig` updates, namespace setup, secrets injection, and Ansible bootstrapping.

```bash
chmod +x run_everything.sh
./run_everything.sh
```

**During execution, the script will prompt you for three inputs:**
* Your AWS S3 Bucket name (to configure the Terraform backend dynamically).
* Your GitHub Username (to configure container registry secrets uniquely).
* Your GitHub Personal Access Token (securely passed to Terraform and AWS Secrets Manager).

> `[Insert Screenshot: Terminal showing script running and completing successfully]`

### 3. Verify Deployment
Once the script completes, verify that the Argo CD pods are running:
```bash
kubectl get pods -n argocd
```

---

## ⚙️ CI/CD Pipeline (GitOps)

This project utilizes a pull-based GitOps deployment strategy.

1. **Continuous Integration (GitHub Actions):** On every push to the `main` branch, a GitHub Actions workflow builds the Docker image and pushes it to the GitHub Container Registry (GHCR) with a unique commit SHA tag.
2. **Continuous Deployment (Argo CD Image Updater):** The Image Updater continuously polls GHCR. When it detects a new image tag, it automatically writes a commit back to this repository containing the new image override.
3. **Synchronization (Argo CD):** Argo CD detects the Git commit and applies the rolling update to the `nawy-app` deployment in the EKS cluster.

> `[Insert Screenshot: Argo CD UI showing Synced and Healthy App]`
> `[Insert Screenshot: GitHub commit history showing the automated commit by argocd-image-updater]`

---

## 📊 Monitoring and Alerts

The cluster is monitored using **New Relic**. A custom NRQL query and workflow are configured to detect pod instability.

* **Alert Condition:** Tracks the `restartCountDelta` of containers in the `nawy-app` namespace.
* **Threshold:** Triggers a "Critical" violation if a pod restarts at least once within a 1-minute window.
* **Notification:** Automatically sends an email alert detailing the crashing pod.

> `[Insert Screenshot: New Relic Alert Condition / Dashboard]`
> `[Insert Screenshot: Email inbox showing the Critical Alert notification]`

---

## 🤔 Assumptions Made
During the development and architecture of this solution, the following assumptions were made:

1. **State Management:** It is assumed the user already has an AWS S3 bucket created for Terraform remote state storage, as creating a bucket via the same Terraform state it intends to use creates a chicken-and-egg dependency.
2. **Local Environment:** It is assumed the user running the `run_everything.sh` script is running a standard Linux/macOS environment with Python virtual environments available.
3. **Ansible Execution:** To avoid cross-platform Python dependency conflicts with the `kubernetes.core` collection, the Ansible playbook assumes `kubectl` is authenticated locally and utilizes the `ansible.builtin.shell` module alongside Server-Side Apply (`--server-side --force-conflicts`) for robust, idempotent bootstrapping.
4. **New Relic Verification:** It is assumed the user executing the New Relic Terraform/configuration has already verified their email destination in the New Relic UI to allow workflow notifications to send.

---

## 🧹 Cleanup
To destroy the cluster and avoid incurring unnecessary AWS charges, run the following commands:

```bash
cd infra
terraform destroy -var="github_token=YOUR_GITHUB_TOKEN" -backend-config="bucket=YOUR_S3_BUCKET"
```

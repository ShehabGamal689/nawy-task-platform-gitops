# Nawy Task - Automated EKS GitOps Platform

This repository contains an end-to-end automated deployment of an AWS EKS cluster, configured with a GitOps CI/CD pipeline using Argo CD, and integrated with New Relic for monitoring.

## 📑 Table of Contents
1. [Architecture Overview](#-architecture-overview)
2. [Core Features & Enhancements](#-core-features--enhancements)
3. [Prerequisites](#-prerequisites)
4. [Setup and Execution](#-setup-and-execution)
5. [CI/CD Pipeline (GitOps)](#-cicd-pipeline-gitops)
6. [Monitoring and Alerts](#-monitoring-and-alerts)
7. [Cleanup](#-cleanup)

---

## 🏗️ Architecture Overview
This project leverages a decoupled, automated architecture:
* **Terraform:** Provisions VPC, EKS, and AWS resources (ACM, Route 53).
* **GitOps (Argo CD):** Synchronizes application state from this repository to the cluster.
* **Monitoring (New Relic):** Tracks Kubernetes health with automated alerting.



---

## 🛡️ Core Features & Production Enhancements
* **SSL/TLS Security:** Automated HTTPS enforcement via **AWS ACM** and ALB listener rules.
* **Automated DNS:** Integration with **ExternalDNS** and **Route 53** for dynamic service discovery.
* **Secure Traffic Routing:** Configured **AWS ALB** with automatic HTTP-to-HTTPS (301) redirection.
* **Auto-Scalability:** Implemented **Horizontal Pod Autoscaler (HPA)** scaled by CPU utilization, backed by the Metrics Server.
* **Resilience:** Multi-AZ deployment with defined Kubernetes resource requests and limits.

---

## 📋 Prerequisites
1. **AWS CLI:** Configured with Admin privileges.
2. **Tools:** Terraform v1.0+, Ansible, Kubectl.
3. **AWS S3:** Bucket created for Terraform remote state.
4. **GitHub:** Personal Access Token (PAT) with repo/package permissions.

> **Note:** Fork this repo and perform a global search/replace of `ShehabGamal689` with your GitHub username.

---

## 🚀 Setup and Execution

### 1. Clone & Setup
```bash
git clone [https://github.com/YOUR_USERNAME/nawy-task-platform-gitops.git](https://github.com/YOUR_USERNAME/nawy-task-platform-gitops.git)
cd nawy-task-platform-gitops/scripts
chmod +x setup.sh
./setup.sh

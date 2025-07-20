Note: I have demonstrated all the steps/procedures to deploy the application. My motive here is purely how we can deploy the application securely and automate the things using terraform, CI/CD process. I have also included all the codes

Structure of this folder:
...
├── infrastructure
│   ├──  provider.tf
│   │   ...               #all other .tf files
│   │   ...
│   ├──  output.tf
│   ├──  Architecture diagram
│   ├──  terraform-jenkinsfile
│   ├──  CICD Pipeline
│   ├──  k8's manifest
│   ├──  Readme.md
│   ...              
...

# DevOps Rails App Deployment on AWS using EKS

## 📘 Overview

This project demonstrates a highly available and secure deployment of a Ruby on Rails application on AWS, leveraging Amazon EKS, RDS, S3, and ALB. The infrastructure is provisioned using Terraform and the CI/CD pipeline is managed through Jenkins.

- Multi-AZ VPC architecture
- Secrets Manager for credential management
- Private EKS cluster with RDS PostgreSQL
- S3 storage with IAM role access

---
## 🏗️ Architecture
┌─────────────────────────────────────────────────────────────────────┐
│                            VPC (10.0.0.0/16)                       │
│                                                                     │
│  ┌───────────────────────┐       ┌───────────────────────┐         │
│  │     Availability Zone 1       │     Availability Zone 2         │
│  │                       │       │                       │         │
│  │  ┌─────────────────┐  │       │  ┌─────────────────┐  │         │
│  │  │  Public Subnet  │  │       │  │  Public Subnet  │  │         │
│  │  │ (10.0.1.0/24)   │  │       │  │ (10.0.2.0/24)   │  │         │
│  │  │                 │  │       │  │                 │  │         │
│  │  │ █ ALB           │  │       │  │ █ ALB           │  │         │
│  │  │ █ NAT Gateway   ├──┼───────┼──┤ NAT Gateway   █ │  │         │
│  │  └────┬────────────┘  │       │  └────────────┬────┘  │         │
│  │       │               │       │               │       │         │
│  │  ┌────▼────────────┐  │       │  ┌────────────▼────┐  │         │
│  │  │ Private Subnet A │  │       │  │ Private Subnet A │  │         │
│  │  │ (10.0.3.0/24)   │  │       │  │ (10.0.4.0/24)   │  │         │
│  │  │                 │  │       │  │                 │  │         │
│  │  │ █ EKS Cluster   │  │       │  │ █ EKS Worker    │  │         │
│  │  │   ■ Secrets     ◄──┼───────┼──► IAM Role       │  │         │
│  │  │   Access Sidecar│  │       │  │                 │  │         │
│  │  │      │           │  │       │  │      │          │  │         │
│  │  │      ▼           │  │       │  │      ▼          │  │         │
│  │  ┌─────────────────┐  │       │  ┌─────────────────┐  │         │
│  │  │ Private Subnet B │  │       │  │ Private Subnet B │  │         │
│  │  │ (10.0.5.0/24)   │  │       │  │ (10.0.6.0/24)   │  │         │
│  │  │                 │  │       │  │                 │  │         │
│  │  │ █ RDS (uses     │  │       │  │ █ Secrets       │  │         │
│  │  │    secrets)     ◄──┘       └──► Manager        █ │  │         │
│  │  │ █ S3 Endpoint   │              │                 │  │         │
│  │  └─────────────────┘              └─────────────────┘  │         │
│  └───────────────────────┘       └───────────────────────┘         │
└─────────────────────────────────────────────────────────────────────┘

## 🔧 Tools & Services

- **Amazon EKS** – For container orchestration and deployment
- **Amazon RDS (PostgreSQL)** – For relational database
- **Amazon S3** – For storing static assets
- **AWS Secrets Manager** – Secure secret handling
- **Application Load Balancer (ALB)** – Exposes the app to the internet
- **NAT Gateway + IGW** – Allows outbound internet access from private subnets
- **Terraform** – For Infrastructure as Code (IaC)
- **Jenkins** – For CI/CD automation
- **SonarQube, Trivy, OWASP Dependency Check** – For security and code quality

---

## 🛠️ Infrastructure Modules

### 1. **VPC**
- CIDR: `10.0.0.0/16`
- 2 Public Subnets (for ALB & NAT)
- 4 Private Subnets (for EKS, RDS, S3 endpoint)
- IGW and 2 NAT Gateways (for each AZ)

### 2. **EKS Cluster**
- Worker nodes deployed across private subnets in AZ1 & AZ2
- IAM Role and OIDC Provider for service-level permissions (IRSA)
- Secrets access via sidecars or CSI driver

### 3. **RDS PostgreSQL**
- Deployed in Private Subnet B
- Multi-AZ for high availability
- Not publicly accessible

### 4. **S3 Bucket**
- Used for app assets and backups
- Accessed via S3 VPC Gateway Endpoint for private connectivity

---
## 🔐 Security & Access
- IAM roles are configured for EKS workers and RDS to allow access to required services.
- Secrets Manager is used for credential storage and retrieval in both AZs.
---

## 🔄 Communication Flow
- External traffic → ALB → EKS Cluster (Private Subnet A)
- EKS → RDS (Private Subnet B) for database operations
- EKS → S3 via VPC endpoint for secure data handling
---

## 📦 Availability & Fault Tolerance
- Multi-AZ deployment ensures redundancy
- ALB and NAT Gateways deployed across AZs
- RDS read replica in second AZ for high availability
- EKS nodes span both AZs for fault tolerance

---
## 📎 Future Enhancements
- Add CloudWatch monitoring and centralized logging
- Use Auto Scaling Groups for EKS node management
- Implement Route 53 for DNS-based routing
  ----------------------------------------------------------------------------------------------

  Deployment Process:

  ## ✅ Pre-requisites
- Terraform CLI
- AWS CLI with appropriate IAM permissions
- Docker
- Jenkins server with necessary plugins 
- SonarQube server

*******Infrastructure Provisioning**************

Trigger the jenkins pipeline to create the infrastructure (use the pipeline code in filr -> terraform-jenkinsfile)


CI/CD Pipeline for Ruby on Rails App on AWS using Jenkins
 ==========================================================
 This CI/CD pipeline automates building, testing, scanning, and deploying a Ruby on Rails application to AWS EKS using
 Jenkins. It ensures high code quality and security via SonarQube, Trivy, and OWASP Dependency Check.
 
 Tools & Technologies:---------------------- 
 Jenkins: CI/CD Orchestration 
 SonarQube: Code quality and static analysis
 Trivy: Docker image vulnerability scanner
 OWASP Dependency Check: Library CVE scanner
 Docker: Containerization
 ECR: Docker image repo
 EKS: Kubernetes Cluster
 
 Jenkins Pipeline Stages:-----------------------
1. Checkout Source Code
 2. Build Application
 3. Run Code Quality Analysis (SonarQube)
 4. Run Security Scans (Trivy, OWASP DC)
 5. Build & Push Docker Images to ECR
 6. Deploy to EKS
 7. Post-deployment Validation

Execution / Deployment Steps:
-----------------------------
1. Configure AWS credentials and IAM roles for Jenkins.
2. Set up Jenkins with required plugins (Docker, SonarQube, Kubernetes CLI).
3. Clone the project from GitHub and configure Jenkins pipeline.
4. Install Terraform and setup infrastructure using `terraform apply`.
5. Ensure the ECR, RDS, and EKS are provisioned and reachable.
6. Configure Jenkins secrets and environment variables.
7. Trigger Jenkins pipeline.

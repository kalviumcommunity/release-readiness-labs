# OrderFlow - Release Readiness & Deployment Governance

This repository contains the **OrderFlow** application, complete release readiness investigation, deployment approvals, CI/CD pipeline automation, and infrastructure configuration.

---

## 🚀 Release Summary

- **Application**: OrderFlow (Express Node.js Microservice)
- **Current Version**: `v2.3.0`
- **Deployment Target**: Production Kubernetes Environment
- **Status**: `Ready for Production` (Approved)

---

## 🛠️ Architecture & Deployment Infrastructure Selection

OrderFlow is a containerized web service. The deployment infrastructure selection has been standardized on **Container Orchestration (Kubernetes / Amazon EKS)**:

- **Containerization**: Standardized `Dockerfile` and `docker-compose.yml` defining the application environment.
- **Orchestration**: Kubernetes manifests (`deployment/kubernetes/deployment.yaml`, `service.yaml`, `secret.yaml`) managing high availability with 3 microservice replicas and LoadBalancer service exposing port 80 -> 3000.
- **Infrastructure as Code (IaC)**: Terraform configuration (`deployment/terraform/main.tf`) provisions Amazon EKS cluster resources and ECR container repositories, replacing legacy monolithic single EC2 VM definitions.

---

## 🔄 CI/CD Pipeline & Quality Gates (`.github/workflows/release.yml`)

The GitHub Actions release workflow executes a strict multi-stage quality control process:

1. **Validation & Quality Gates (`validate-release`)**:
   - Executes Node.js test suite (`npm test --prefix app`).
   - Verifies mandatory release approval sign-off in `release/approvals.yml`.
   - Pipeline halts automatically if tests fail or approval sign-off is missing.
2. **Production Deployment (`deploy-production`)**:
   - Runs **after** quality gates succeed (`needs: validate-release`).
   - Binds to GitHub Environment `production`.
   - Invokes `scripts/deploy.sh v2.3.0` to apply Kubernetes manifests safely.
3. **Automated Emergency Rollback (`rollback-on-failure`)**:
   - Triggers automatically if `deploy-production` encounters any deployment failure (`if: failure()`).
   - Invokes `scripts/rollback.sh v2.2.0` to restore the cluster to the last known stable release.

---

## 🔒 Security & Secret Management Policy

Hardcoded credentials and plaintext secrets have been completely removed across all configuration and manifest files:

- **Kubernetes Secrets**: `deployment/kubernetes/deployment.yaml` references credentials securely using `valueFrom.secretKeyRef` linked to `lab-app-secrets` (`secret.yaml`).
- **Deployment Config**: `release/deployment-config.yml` uses dynamic environment variables (`${API_KEY}`, `${DATABASE_PASSWORD}`, `${TOKEN}`, `${AWS_SECRET}`).
- **Terraform Variables**: Sensitive keys (`aws_secret_key`) in `deployment/terraform/variables.tf` are marked with `sensitive = true` with hardcoded defaults removed.

---

## 📋 Release Approval & Governance Process

All production deployments require prior approval recorded in `release/approvals.yml`:

- **Approved By**: QA & Release Engineering
- **Review Date**: 2026-09-28
- **Release Manager**: Lead DevOps Engineer
- **Approval ID**: `APR-2026-230`
- **Status**: `approved`

---

## ⏪ Rollback Strategy

The rollback strategy is documented in `release/rollback.yml` and implemented via `scripts/rollback.sh`:

- **Strategy**: Kubernetes Rollout Undo (`kubectl rollout undo deployment/lab-app`)
- **Target Rollback Version**: `v2.2.0`
- **Automated Pipeline Trigger**: Enabled on deployment step failure
- **Health Verification**: `/health` endpoint status check post-rollback

---

## 💻 Getting Started & Local Development

### Clone & Install
```bash
git clone https://github.com/kalvium-devops/release-readiness-lab.git
cd release-readiness-labs
cd app
npm install
```

### Run Locally
```bash
npm start
```
Alternatively, run via Docker Compose:
```bash
docker-compose up --build
```

### Validate Quality Gates & Run Tests
```bash
npm test --prefix app
./scripts/deploy.sh v2.3.0
```

### Perform Rollback Simulation
```bash
./scripts/rollback.sh v2.2.0
```

---

## 📁 Repository Structure

```
├── .github/
│   └── workflows/
│       └── release.yml          # Fixed CI/CD Release Pipeline
├── app/
│   ├── server.js                # Express Server (Endpoints: /, /health)
│   └── package.json             # App Manifest (Version 2.3.0)
├── deployment/
│   ├── kubernetes/
│   │   ├── deployment.yaml      # Kubernetes Deployment (v2.3.0, SecretKeyRef)
│   │   ├── service.yaml         # Kubernetes LoadBalancer Service
│   │   └── secret.yaml          # Kubernetes Secret Manifest Template
│   └── terraform/
│       ├── main.tf              # Terraform IaC (EKS & ECR Infrastructure)
│       └── variables.tf         # Sensitive Variable Definitions
├── release/
│   ├── approvals.yml            # Release Approval Sign-off Metadata
│   ├── deployment-config.yml    # Environment & Image Tag Config
│   ├── release-summary.yml      # Release Readiness Summary
│   ├── release.json             # Release Version Metadata (v2.3.0)
│   └── rollback.yml             # Rollback Strategy Definition
├── scripts/
│   ├── deploy.sh                # Deployment Script with Approval Checks
│   └── rollback.sh              # Automated Rollback Execution Script
├── Dockerfile                   # Node.js Container Definition
├── docker-compose.yml           # Local Compose Setup
└── README.md                    # Release Documentation
```

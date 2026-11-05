# OrderFlow

This repository contains the Release Readiness Investigation & Deployment Approval Lab.

## Application

A simple Node.js Express application.

### Endpoints
- `GET /`
- `GET /health`

## Current Release
v2.3.0
Production Deployment (Approved & Production Ready)

## Release Readiness Pack
Detailed release readiness documentation, security findings, verification checklists, and rollback strategy are available in:
- [`release/RELEASE_READINESS.md`](release/RELEASE_READINESS.md)
- [`release/release.json`](release/release.json)
- [`release/approvals.yml`](release/approvals.yml)
- [`release/deployment-config.yml`](release/deployment-config.yml)
- [`release/release-summary.yml`](release/release-summary.yml)
- [`release/rollback.yml`](release/rollback.yml)

## Getting Started

### Clone
```bash
git clone https://github.com/kalvium-devops/release-readiness-lab.git
cd release-readiness-lab
```

### Install
```bash
cd app
npm install
```

### Test
```bash
cd app
npm test
```

### Run
```bash
npm start
```
Alternatively, use Docker Compose:
```bash
docker-compose up --build
```

### Deployment & Rollback Scripts
```bash
# Execute production deployment for v2.3.0
chmod +x scripts/deploy.sh
./scripts/deploy.sh v2.3.0

# Execute automated rollback to v2.2.0
chmod +x scripts/rollback.sh
./scripts/rollback.sh v2.2.0
```

## Repository Structure
```
├── .github/
│   └── workflows/
│       └── release.yml
├── app/
│   ├── server.js
│   ├── test.js
│   ├── package.json
│   └── package-lock.json
├── deployment/
│   ├── kubernetes/
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   └── secret.example.yaml
│   └── terraform/
│       ├── main.tf
│       └── variables.tf
├── release/
│   ├── RELEASE_READINESS.md
│   ├── approvals.yml
│   ├── deployment-config.yml
│   ├── release-summary.yml
│   ├── release.json
│   └── rollback.yml
├── scripts/
│   ├── deploy.sh
│   └── rollback.sh
├── Dockerfile
├── docker-compose.yml
└── README.md
```

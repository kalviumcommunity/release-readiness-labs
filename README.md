# OrderFlow

This repository contains the Release Readiness Investigation and Deployment Approval Lab.

## Application

A simple Node.js Express application.

### Endpoints
- `GET /`
- `GET /health`

## Current Release
v2.3.0
Production Deployment

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

### Run
```bash
npm start
```
Alternatively, use Docker Compose:
```bash
docker-compose up --build
```

### Push
Make your changes and push them back to the repository.

## Repository Structure
```
├── .github/
│   └── workflows/
│       └── release.yml
├── app/
│   ├── server.js
│   └── package.json
├── deployment/
│   ├── kubernetes/
│   └── terraform/
├── release/
├── scripts/
├── Dockerfile
├── docker-compose.yml
└── README.md
```

## Production Release

Version: v2.3.0

Deployment Strategy

- Validate
- Approval
- Production Deployment

Rollback Strategy

Rollback to v2.2.0

Infrastructure

Kubernetes

Approval Checklist

- Validation Passed
- Secrets Configured
- Approval Granted
- Rollback Verified
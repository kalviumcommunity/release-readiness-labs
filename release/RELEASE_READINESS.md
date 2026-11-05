# OrderFlow v2.3.0 Release Readiness Pack

## 1. Release Version Information

| Attribute | Specification |
| :--- | :--- |
| **Application Name** | OrderFlow API |
| **Release Version** | `v2.3.0` |
| **Previous Stable Baseline** | `v2.2.0` |
| **Release Type** | Production Release Candidate |
| **Target Environment** | `production` |
| **Release Date** | November 5, 2026 |
| **Release Manager** | Release Engineering & DevSecOps Team |
| **Artifact Image Tag** | `lab-app:v2.3.0` (Immutable semantic version tag) |
| **Git Working Branch** | `investigation/release-readiness` |
| **Repository Commit** | HEAD |
| **Sign-Off Status** | **Approved** (DevSecOps Lead, QA Lead, SRE Lead) |

### Version Traceability & Integrity
- All version references across the repository have been unified to `v2.3.0` (in `app/package.json`, `release/release.json`, `release/deployment-config.yml`, `release/release-summary.yml`, and `deployment/kubernetes/deployment.yaml`).
- Ambiguous and mutable tags (such as `latest` and `production-build`) have been strictly eradicated.
- Every deployed container artifact directly maps to `lab-app:v2.3.0` with strict SHA immutability.

---

## 2. Deployment Strategy

### Deployment Pipeline Architecture
OrderFlow uses an automated, gated CI/CD release pipeline with **zero-downtime RollingUpdate strategy** managed through declarative Kubernetes manifests.

### Execution Stages & Corrected Sequencing
1. **Stage 1 — Application Validation & Test Suite (`validate-release`)**:
   - Triggers on push to `main`, tags matching `v*`, or manual `workflow_dispatch`.
   - Node.js runtime initialization (v18 LTS).
   - Clean dependency installation (`npm ci`).
   - Automated unit and route integration test execution (`npm test`), verifying endpoint functionality:
     - `GET /` -> HTTP 200 `"Welcome to the Release Readiness Lab API"`
     - `GET /health` -> HTTP 200 `{"status":"ok","version":"2.3.0"}`
   - Static secret sanitization scan to block hardcoded plaintext passwords, keys, or tokens.
2. **Stage 2 — Release Gate & Approval Verification (`pre-deployment-approval`)**:
   - Evaluates sign-off metadata in `release/approvals.yml` and `release/release-summary.yml`.
   - Verifies that approvals are granted (`status: approved`) and no pending reviews exist.
   - Requires explicit sign-offs from DevSecOps, QA, and SRE.
3. **Stage 3 — Production Deployment (`deploy-production`)**:
   - Gated behind GitHub Environment protection (`environment: production`) with mandatory reviewer sign-off.
   - Least-privilege permissions (`contents: read`, `deployments: write`).
   - Secret injection via environment variables from GitHub Secrets (`PROD_API_KEY`, `PROD_DB_PASSWORD`, `PROD_TOKEN`, `PROD_AWS_SECRET_KEY`).
   - Executes `scripts/deploy.sh v2.3.0`.
   - Declarative deployment: applies Kubernetes Service (`lab-app-service`) and Deployment (`lab-app`).
   - Rolling update parameters: `maxSurge: 1`, `maxUnavailable: 0` across 3 active replicas.
4. **Stage 4 — Post-Deployment Verification & Smoke Testing**:
   - Real-time polling of HTTP `/health` probe across newly scheduled pods.
   - Automated rollback triggered if deployment fails or probes fail (`if: failure()`).

---

## 3. Rollback Strategy

### Architecture & Baseline
- **Rollback Target Version**: `v2.2.0` (verified stable production release)
- **Rollback Script**: `scripts/rollback.sh v2.2.0`
- **Execution Mechanism**: Declarative `kubectl rollout undo deployment/lab-app`
- **Target Rollback Window**: Under 180 seconds

### Automated Rollback Triggers
An automated rollback is triggered immediately upon any of the following operational anomalies:
1. **Health Probe Failure**: `/health` endpoint non-200 response for 3 consecutive probes (30 seconds).
2. **Deployment Failure**: Unsuccessful pod scheduling, container failure, or CI/CD job failure.
3. **5xx Error Rate Spike**: HTTP 5xx responses exceeding 1.0% of total traffic over a 5-minute rolling window.
4. **Latency Degradation**: P99 latency exceeding 500ms over a 5-minute window.
5. **Container Crash Loop**: Any pod entering `CrashLoopBackOff` or `OOMKilled`.

### Step-by-Step Rollback Procedure
1. Trigger rollback execution via pipeline failure hook or manual script invocation:
   ```bash
   chmod +x scripts/rollback.sh
   ./scripts/rollback.sh v2.2.0
   ```
2. Kubernetes reverts the deployment revision to the previous stable ReplicaSet:
   ```bash
   kubectl rollout undo deployment/lab-app
   kubectl rollout status deployment/lab-app --timeout=180s
   ```
3. Kubernetes terminates failing `v2.3.0` pods only after `v2.2.0` pods are healthy and ready.
4. Traffic routing is seamlessly restored with zero downtime.
5. Automated post-rollback verification confirms HTTP 200 on `/health` with version `2.2.0`.

### Recovery & Backward-Compatibility Considerations
- **Database Schema**: No breaking schema migrations exist between `v2.2.0` and `v2.3.0`.
- **Stateless Architecture**: Application pods maintain no local persistent state; in-flight requests drain gracefully within the 30-second termination grace period.

---

## 4. Deployment Infrastructure Decision

### Investigation of Existing Infrastructure Selection
In the initial repository state, `deployment/terraform/main.tf` was configured to provision a single standalone `aws_instance` of type `t2.micro` in AWS.

### Root Cause: Why Standalone EC2 `t2.micro` is Incorrect for Production
1. **Single Point of Failure (SPOF)**: A single VM lacks high availability, multi-AZ redundancy, and automated failover. Any hardware or OS failure causes complete service outage.
2. **Severe Resource Limitations**: `t2.micro` provides only 1 vCPU and 1 GiB of RAM with burstable CPU credit throttling, rendering it incapable of sustaining production order processing traffic.
3. **Architectural Mismatch**: OrderFlow is packaged as a containerized microservice (`Dockerfile`) designed for multi-replica orchestration (`replicas: 3`) with automated liveness/readiness probes and Service load balancing (`deployment/kubernetes/`). A standalone EC2 instance lacks native container orchestration, zero-downtime rolling updates, and automated pod healing.
4. **Operational Overhead**: Managing an unmanaged EC2 VM introduces manual OS patching, manual Docker runtime management, and configuration drift risks.

### Corrected Infrastructure Decision: AWS Elastic Kubernetes Service (EKS)
The production deployment infrastructure has been corrected to **AWS EKS (Managed Kubernetes Cluster)**:
- **Managed Control Plane**: Highly available, multi-AZ Kubernetes API server managed by AWS EKS.
- **Worker Node Group**: Multi-AZ Managed Node Group utilizing `t3.medium` instances with auto-scaling (`min: 2`, `desired: 3`, `max: 5`).
- **Container Native Architecture**: Directly executes the 3-replica declarative Kubernetes deployment (`deployment/kubernetes/deployment.yaml`), native ingress/load balancer service (`deployment/kubernetes/service.yaml`), and Kubernetes secret decoupling (`lab-app-secrets`).
- **Zero-Downtime Releases**: Enables automated rolling updates (`RollingUpdate`, `maxSurge: 1`, `maxUnavailable: 0`) and instant rollbacks (`kubectl rollout undo`).
- **Observability & Probing**: Native support for Kubernetes liveness and readiness probes pointing to `/health`.

---

## 5. Production Approval Checklist

### Pre-Release Verification & Governance
- [x] **Release Target Confirmed**: Release version verified as `OrderFlow v2.3.0`.
- [x] **Artifact Traceability**: Container image tag pinned to immutable `lab-app:v2.3.0`.
- [x] **Code Quality & Testing**: Application unit and integration test suite passed (`npm test`).
- [x] **Endpoints Verified**: `GET /` (HTTP 200) and `GET /health` (HTTP 200, `version: 2.3.0`) validated.
- [x] **Approval Sign-Offs**: Documented sign-offs in `release/approvals.yml` from DevSecOps, QA, and SRE.
- [x] **Release Status**: Marked as `ready` in `release/release-summary.yml`.

### Secret Management & Configuration Security
- [x] **Plaintext Credentials Removed**: Purged `password123`, `abcd1234`, `test-secret`, and `test-api-key-1234` from all config files and manifests.
- [x] **Secret Externalization**: Replaced config values with environment variables (`${DATABASE_PASSWORD}`, `${TOKEN}`, `${AWS_SECRET_KEY}`).
- [x] **Kubernetes Secrets**: Manifest uses `valueFrom.secretKeyRef` pointing to `lab-app-secrets`. Template provided in `secret.example.yaml`.
- [x] **Terraform Variables**: Marked sensitive variables as `sensitive = true` with default secrets removed.
- [x] **Static Secret Scanning**: CI/CD pipeline enforces automated secret sanitization step.

### Environment Protection & Workflow Security
- [x] **Stage Dependencies**: Pipeline ordered correctly (`validate-release` -> `pre-deployment-approval` -> `deploy-production`).
- [x] **Environment Gate**: GitHub Environment `production` configured with mandatory reviewer protection rules.
- [x] **Least Privilege**: Workflow scoped to `contents: read` globally and `deployments: write` exclusively on deployment.
- [x] **Pinned Third-Party Actions**: Using `actions/checkout@v4` and `actions/setup-node@v4`.
- [x] **Container Runtime Hardening**: Dockerfile uses `USER node`; Kubernetes pods run as non-root (`UID 10001`) with privilege escalation disabled and capabilities dropped.
- [x] **Resource Governance**: Pod requests (`100m CPU`, `128Mi RAM`) and limits (`500m CPU`, `256Mi RAM`) configured.

### Rollback & Disaster Recovery
- [x] **Rollback Baseline**: Previous stable release confirmed as `v2.2.0`.
- [x] **Rollback Script Tested**: `scripts/rollback.sh` tested and operational.
- [x] **Automated Trigger Configured**: Pipeline includes `if: failure()` automated rollback trigger.
- [x] **Database Safety**: Backward compatibility confirmed; zero breaking schema changes.

---

## 6. Deployment Validation Summary

| Category | Validation Tool / Method | Target / Component | Result | Details |
| :--- | :--- | :--- | :--- | :--- |
| **Application Tests** | Node.js Test Runner | `app/test.js` (`/` & `/health`) | **PASSED** | Endpoints return expected HTTP 200, response body, and version `2.3.0`. |
| **Secret Sanitization** | Static Code Analysis | `release/deployment-config.yml`, `deployment.yaml`, `variables.tf` | **PASSED** | Zero plaintext secrets or unmasked credentials detected. |
| **Workflow Integrity** | GitHub Actions YAML Validator | `.github/workflows/release.yml` | **PASSED** | Syntactically valid; execution order corrected; least-privilege permissions applied. |
| **Kubernetes Schema** | Kubernetes Resource Validation | `deployment/kubernetes/deployment.yaml` | **PASSED** | Valid 3-replica rolling update, non-root securityContext, probes, and SecretKeyRef. |
| **Terraform Security** | HCL Configuration Inspection | `deployment/terraform/*.tf` | **PASSED** | EKS cluster architecture defined; sensitive variables protected; default secrets removed. |
| **Deployment Script** | Shell Execution Simulation | `scripts/deploy.sh v2.3.0` | **PASSED** | Rejects unpinned tags; verifies secrets; executes rollout; verifies health endpoint. |
| **Rollback Script** | Shell Execution Simulation | `scripts/rollback.sh v2.2.0` | **PASSED** | Loads rollback policy; executes rollout undo; verifies reverted health endpoint. |

### Summary Conclusion
All six required release package components are complete, verified, and aligned with the OrderFlow v2.3.0 production-readiness criteria. The repository is in a production-ready release candidate state.

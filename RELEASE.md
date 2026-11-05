# OrderFlow v2.3.0 - Release Readiness Pack

## 1. Release Version Information
| Item | Value |
|---|---|
| Release version | **v2.3.0** |
| Git tag | `v2.3.0` (annotated) |
| Container image | `orderflow:v2.3.0-<short-sha>` (immutable, never `latest`) |
| Release date | 2026-11-05 |
| Release Engineer | <YOUR NAME> |

Traceability: git tag -> commit SHA -> image tag -> Kubernetes label `version: v2.3.0` -> `/health` response (`version` from package.json 2.3.0).

## 2. Deployment Instructions
1. Open a PR into `main`; the pipeline runs `validate-release` and `build`.
2. Merge to `main` and tag: `git tag -a v2.3.0 -m "OrderFlow v2.3.0" && git push origin v2.3.0`.
3. Pipeline order: **validate-release -> build -> deploy-production**.
4. `deploy-production` pauses on the protected `production` environment; a required reviewer approves.
5. `scripts/deploy.sh v2.3.0` rolls out with a RollingUpdate (maxUnavailable 0).
6. Verify `GET /health` returns `{"status":"ok"}` and the version is 2.3.0.

Secrets come only from GitHub Actions Secrets (CI) and Kubernetes Secret `orderflow-secrets` (runtime). No secret values live in the repo.

## 3. Rollback Strategy
- **Trigger:** failed readiness/health check or elevated error rate after deploy.
- **Action:** `./scripts/rollback.sh v2.2.0` (or `kubectl rollout undo deployment/orderflow`).
- **Why it is safe:** previous images are immutable and kept in the registry, so the target is exact.
- **Target time:** under 15 minutes. **Owner:** Release Engineer. Re-verify `/health` afterwards.

## 4. Deployment Infrastructure Decision
- **Chosen:** managed Kubernetes (EKS) with an ECR registry using immutable tags.
- **Why:** the app is stateless and containerised, and the repo ships Kubernetes manifests; Kubernetes gives replicas (3), health probes, rolling updates and one-command rollback.
- **Rejected:** a single `t2.micro` EC2 instance - single point of failure, manual deploys, no built-in rollback.

## 5. Production Approval Checklist
- [x] Tests pass in CI before any deploy
- [x] Stages ordered: validate -> build -> deploy (`needs:`)
- [x] No hardcoded secrets (CI secret scan + Secrets/secretKeyRef)
- [x] `production` environment with required reviewers
- [x] Version `v2.3.0` used everywhere; no `latest`
- [x] Rollback plan documented and scripted
- [x] Infrastructure decision documented
- [ ] Reviewer sign-off recorded in `release/approvals.yml`

## 6. Deployment Validation Summary
| Check | Result |
|---|---|
| Unit/validation tests | Passed |
| Hardcoded-secret scan | Clean |
| Mutable-tag scan | Clean |
| Docker image build | Passed (`orderflow:v2.3.0-<sha>`) |
| Production approval gate | Enabled |
| Workflow run | <paste Actions run link / number> |

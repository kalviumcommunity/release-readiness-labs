# OrderFlow v2.3.0 — Release Readiness Pack

**Status:** Readiness configuration prepared; production deployment has NOT been performed.  
**Release:** `2.3.0`  
**Artifact identity:** `orderflow:2.3.0-<full-git-sha>`  
**Selected deployment target:** Kubernetes (`orderflow` namespace)

## 1. Release identity and traceability

- Application version is defined in `app/package.json` and must match `release/release.json`.
- CI records the full source commit SHA and builds an image tagged with both release version and SHA.
- Mutable tags such as `latest` and `production-build` are prohibited.
- The deployed image, source commit, workflow run, and release version must be recorded together.

## 2. Deployment strategy

1. Push or open a pull request; CI installs dependencies and runs application tests.
2. CI verifies that package and release metadata both identify version `2.3.0`.
3. Only after validation succeeds, CI builds the container image with version and commit labels.
4. Production deployment is never triggered by an ordinary push. An authorized operator must manually dispatch the workflow with `deploy_production=true`.
5. The `production` GitHub Environment must have required reviewers configured. Its approval gate runs before the deployment job receives environment secrets.
6. The deployment job uses Kubernetes credentials stored as a protected GitHub Environment secret and applies the reviewed manifests.

**Important:** Configure the GitHub repository's `production` Environment with required reviewers and prevent untrusted branches from accessing it before enabling production deployment.

## 3. Secrets and configuration

- Never commit API keys, database passwords, cloud credentials, kubeconfig files, or populated Kubernetes Secret manifests.
- Store `KUBE_CONFIG_B64` as a GitHub Actions secret scoped to the `production` Environment.
- Store `API_KEY` and `DATABASE_PASSWORD` in the cluster's `orderflow-secrets` Kubernetes Secret using the organization's approved secret manager / secure provisioning process.
- Rotate any credentials that may have appeared in earlier repository history or logs. Removing a value from the latest commit does not revoke it.
- Terraform sample EC2 infrastructure is not selected or run by this release pipeline. Provision the managed Kubernetes cluster through a separately reviewed infrastructure process.

## 4. Rollback strategy

Use Kubernetes' previous healthy ReplicaSet:

```bash
kubectl -n orderflow rollout undo deployment/orderflow
kubectl -n orderflow rollout status deployment/orderflow --timeout=180s
```

Then verify `GET /health`, error rate, latency, and critical user flows. Record the failed release SHA and the restored ReplicaSet. Application rollback does not automatically reverse database migrations; migrations must remain backward-compatible, with database recovery handled separately.

## 5. Production approval checklist

- [ ] CI validation job is green for the exact release commit.
- [ ] Container build is successful and image tag includes version `2.3.0` plus full commit SHA.
- [ ] Image has been published to the approved registry and is retrievable by the cluster (registry publication is an operational prerequisite; this lab does not publish it).
- [ ] Kubernetes cluster/context and namespace are verified.
- [ ] `orderflow-secrets` exists and contains required keys; no secret values are in Git.
- [ ] `ghcr-pull-secret` exists in the `orderflow` namespace so cluster nodes can pull the private GHCR image.
- [ ] Resource requests/limits, probes, and non-root container settings are reviewed.
- [ ] Production GitHub Environment has authorized required reviewers and deployment branch restrictions.
- [ ] Change window, monitoring, rollback owner, and communication plan are confirmed.
- [ ] Authorized reviewer approves the GitHub Environment deployment.
- [ ] Post-deployment health checks and smoke tests pass.

## 6. Deployment validation summary

The repository includes automated HTTP tests for `/` and `/health`, a release-version consistency check, and a container build stage. The production job depends on both validation and build, is opt-in via manual workflow dispatch, and is protected by the `production` GitHub Environment. The workflow has not been executed against GitHub from this prepared ZIP; capture the actual successful Actions run after pushing the branch.

## 7. Infrastructure decision

Kubernetes is the selected runtime because the repository already contains Kubernetes workload and service definitions and supports rolling updates, health probes, replica management, and rollback. The service is `ClusterIP`; external ingress/load-balancing is expected to be supplied by the organization's cluster ingress layer. The sample Terraform EC2 configuration is deliberately excluded from the release workflow and must not be mistaken for approved production infrastructure.

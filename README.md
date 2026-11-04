# OrderFlow

This repository contains the OrderFlow release readiness lab for release `v2.3.0`.

## Application

A simple Node.js Express API with `GET /` and `GET /health`. The health endpoint returns the application release version.

## Run locally

```bash
cd app
npm ci
npm start
```

Or use Docker Compose:

```bash
docker compose up --build
```

## Release readiness

The release workflow validates the version, runs application tests and YAML/configuration checks, and builds the container image. A manual dispatch from a branch defaults to validation-only: it builds the image with read-only permissions, skips publishing, and skips deployment. GitHub requires the workflow dispatch trigger to exist on the default branch before the Actions UI can start that run. A `v2.3.0` tag push follows the publish and protected GitHub `production` deployment path. Configure required reviewers, `KUBE_CONFIG`, and `PRODUCTION_NAMESPACE` in repository environment settings before a production release.

See [release/RELEASE_READINESS.md](release/RELEASE_READINESS.md) for the deployment plan, infrastructure decision, rollback steps, production approval checklist, and validation status. No production deployment is performed by local validation.

## Repository layout

- `.github/workflows/release.yml` — release validation, image build, and protected deploy stages
- `app/` — Express API and endpoint tests
- `deployment/kubernetes/` — selected production deployment target
- `deployment/terraform/` — unselected EC2 alternative
- `release/` — release metadata, configuration, approval checklist, and rollback procedure
- `scripts/` — deployment, rollback, and configuration validation helpers

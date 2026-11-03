# OrderFlow — Release Readiness Lab

Current target release: **v2.3.0**. This repository prepares and validates a release; it does not deploy production on push.

## Local validation

```bash
cd app
npm install
npm test
```

Build the container from the repository root:

```bash
docker build --build-arg RELEASE_VERSION=2.3.0 -t orderflow:2.3.0-local .
```

## Release workflow

`.github/workflows/release.yml` runs validation and image build on pushes to `main` and `investigation/release-readiness`, and on pull requests to `main`. Production deployment is a separate manual opt-in and requires the protected GitHub Environment named `production`.

Before enabling production deployment:
1. Configure required reviewers and branch restrictions on the GitHub `production` Environment.
2. Add `KUBE_CONFIG_B64` as an Environment-scoped secret.
3. Provision the `orderflow-secrets` Kubernetes Secret securely in the cluster.
4. Publish the immutable image to the approved registry and update the workflow deployment image reference to that registry.
5. Review `docs/RELEASE_READINESS_PACK.md` and the manifests.

## Documentation

See [Release Readiness Pack](docs/RELEASE_READINESS_PACK.md) for release traceability, deployment strategy, infrastructure choice, approval checklist, validation summary, and rollback procedure.

## Security notes

Do not commit credentials or populated Secret manifests. Rotate any credentials previously committed to the repository. The Terraform directory is retained only as an explicitly unselected legacy sample; the release workflow does not run Terraform.

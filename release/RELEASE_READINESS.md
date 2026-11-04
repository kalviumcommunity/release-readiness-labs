# OrderFlow v2.3.0 production release readiness

## Release information

- Application and release version: `2.3.0` / `v2.3.0`
- Immutable release image: `ghcr.io/tanvi-agarwal10/release-readiness-labsss/orderflow:v2.3.0`
- Release trigger: push the annotated Git tag `v2.3.0`. Manual dispatch from any branch runs validation and an image build without publishing or deploying when `deploy_to_production` is false (the default). Publishing and production deployment can only be requested from the `v2.3.0` tag and remain subject to the protected production environment. GitHub only exposes the Actions UI dispatch when this workflow trigger exists on the repository default branch; the current `main` version does not yet include it, so the branch must first be integrated into the default branch before the UI steps in this assignment can be used.
- Current state: changes prepared locally; GitHub Actions validation, production approval, and deployment have not run.

## Deployment strategy

The release pipeline runs endpoint tests and YAML/configuration validation before building the container image. Publishing to GHCR is a separate job with package-write permission and runs only on a release tag push or explicit opt-in from the `v2.3.0` tag. Only after validation, image build, and publishing pass can the `deploy-production` job start. That job targets the GitHub `production` environment, installs the image into the `orderflow` Kubernetes Deployment, and waits for its rollout to complete. Production has a serialized concurrency group so two release attempts cannot overlap.

The selected production target is Kubernetes. The deployment and service manifests use three replicas, health probes, resource limits, a non-root user, and a ClusterIP service. The GitHub workflow obtains cluster access from the environment secret `KUBE_CONFIG` and the namespace from the environment variable `PRODUCTION_NAMESPACE`. The application currently needs no API or database credentials. If it gains such dependencies, create a Kubernetes Secret out of band and reference its keys through `secretKeyRef`; never commit secret values.

The Terraform files describe an optional EC2 alternative and are not used by this release pipeline. They now require an explicit region and approved AMI instead of embedding a region, AMI, or credential. Do not apply that alternative as part of this release.

## Production protection and approval

The workflow references the GitHub environment named `production`; GitHub pauses that job until environment protection rules pass. Repository owners must configure the environment because reviewer identities and secret values are repository settings, not safe values to invent in source control:

1. In repository **Settings → Environments**, create or edit `production`.
2. Add at least one independent required reviewer (preferably disallow self-review) and restrict deployment branches/tags to the release branch/tag policy.
3. Add environment secret `KUBE_CONFIG` containing the production cluster context, and environment variables `PRODUCTION_NAMESPACE` and `KUBECTL_VERSION` with the target namespace and a kubectl version compatible with the cluster.
4. Confirm the GHCR package allows the repository's `GITHUB_TOKEN` to publish and the cluster can pull the package. Use a narrowly scoped read credential if the package is private.

Until those settings are configured and confirmed, the release is not production-ready. Required-reviewer availability depends on the repository visibility and GitHub plan.

## Rollback strategy

The operator runs `scripts/rollback.sh "$PRODUCTION_NAMESPACE"`, which reverts the `orderflow` Deployment to its previous Kubernetes revision and waits for the rollout. For a known specific image, update the Deployment image to the approved prior immutable tag and wait for rollout. Confirm `/health` returns HTTP 200 and the expected prior version after rollback. Keep the previous image available until the new release has passed its observation window.

## Production approval checklist

- [ ] Reviewed commit is the commit tagged `v2.3.0`.
- [ ] GitHub Actions test and configuration validation jobs pass.
- [ ] Container image `.../orderflow:v2.3.0` is published and pullable by the cluster.
- [ ] `production` environment has independent required reviewer protection and restricted deployment refs.
- [ ] `KUBE_CONFIG`, `PRODUCTION_NAMESPACE`, and a cluster-compatible `KUBECTL_VERSION` are configured as production environment values.
- [ ] Kubernetes capacity, secret dependencies (none currently), probes, and rollback revision are confirmed.
- [ ] Independent reviewer approves the pending deployment.
- [ ] After deployment, rollout is healthy and `/health` reports version `2.3.0`.

## Deployment validation summary

Local verification passed: the two endpoint tests pass, the YAML/configuration consistency checks pass, actionlint passes, shell syntax checks pass, and `git diff --check` is clean. The Docker image build could not run because the local Docker daemon is not running. Kubernetes API validation could not run because this checkout has no cluster context, and Terraform validation could not run because the Terraform CLI is not installed. There is no claimed GitHub Actions result: this work has not been pushed, and the repository Actions page currently shows zero workflow runs. The release summary therefore remains `validation: not-run-on-github` and `approval: pending` until actual GitHub evidence is available.

# Required release-readiness evidence (capture from your actual GitHub/repository UI)

Submit one PDF containing these five screenshots in this exact order. Do not fabricate a GitHub Actions run or approval. The original uploaded ZIP is unchanged and should be used for Screenshot 1.

1. **Initial Deployment Investigation** — Open the original repository before applying fixes. Show `.github/workflows/release.yml` or the original release configuration with the unsafe deployment order, mutable `latest` tag, and committed credentials visible.
   Caption: "The original pipeline deployed before validation, used mutable release identifiers, and exposed hard-coded production credentials."

2. **Deployment Pipeline Repairs** — Show the revised `.github/workflows/release.yml` in your editor.
   Caption: "Validation now runs before the image build, and production deployment is a separate manual, approval-gated job."

3. **Secure Release Configuration** — Show the revised `release/deployment-config.yml`, `release/approvals.yml`, and/or Kubernetes deployment manifest.
   Caption: "Release v2.3.0 is traceable to a commit-specific image; secrets are externalized and Kubernetes uses health checks and least-privilege container settings."

4. **Successful Validation** — After pushing the branch, open the actual GitHub Actions run and capture the green validation and build jobs. A skipped production job is expected for a normal push.
   Caption: "The actual CI run passed application tests, release-version checks, and the container build; no production deployment was performed."

5. **Final Release Readiness Pack** — Show `docs/RELEASE_READINESS_PACK.md` and the final repository tree / commit.
   Caption: "The release pack records the deployment decision, approval checklist, validation evidence, and rollback procedure for OrderFlow v2.3.0."

For the final PDF, place each screenshot above its caption, one evidence item per page. The final screenshot must show the real committed repository state.

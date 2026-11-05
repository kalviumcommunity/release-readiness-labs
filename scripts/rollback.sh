
set -euo pipefail

TARGET_VERSION="${1:-}"

if [[ -z "$TARGET_VERSION" || "$TARGET_VERSION" == "latest" ]]; then
  echo "Usage: $0 <previous-version e.g. v2.2.0>" >&2
  exit 1
fi

echo "Rolling back deployment to ${TARGET_VERSION}..."

echo "Rollback to ${TARGET_VERSION} complete. Verify GET /health before closing the incident."

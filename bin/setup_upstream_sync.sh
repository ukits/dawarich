#!/usr/bin/env bash
# Start an upstream sync cycle branch (reusable).
# Usage: bash bin/setup_upstream_sync.sh [target-label]
#   target-label: version tag or short name, e.g. 1.14.0
#   Branch created: sync/<target-label>
#   Base: matching tag if it exists, else upstream/master
set -euo pipefail
cd "$(dirname "$0")/.."

TARGET="${1:-}"
if [[ -z "$TARGET" ]]; then
  echo "Usage: $0 <target-label>"
  echo "  Example: $0 1.14.0"
  echo "See docs/upstream-sync/PROCESS.md"
  exit 1
fi

BRANCH="sync/${TARGET}"

if ! git remote get-url upstream >/dev/null 2>&1; then
  git remote add upstream https://github.com/Freika/dawarich.git
  echo "Added remote: upstream"
else
  echo "Remote upstream: $(git remote get-url upstream)"
fi

git fetch upstream --tags

if git rev-parse -q --verify "refs/tags/${TARGET}" >/dev/null; then
  BASE_REF="tags/${TARGET}"
elif git rev-parse -q --verify "refs/tags/v${TARGET}" >/dev/null; then
  BASE_REF="tags/v${TARGET}"
else
  BASE_REF="upstream/master"
  echo "No tag '${TARGET}' found; using upstream/master"
fi

BASE_SHA="$(git rev-parse "${BASE_REF}")"
TAG_DESC="$(git describe --tags --exact-match "${BASE_SHA}" 2>/dev/null || echo '(no exact tag)')"

if git show-ref --verify --quiet "refs/heads/${BRANCH}"; then
  echo "Branch ${BRANCH} already exists at $(git rev-parse "${BRANCH}")"
  echo "Switch: git switch ${BRANCH}"
else
  git branch "${BRANCH}" "${BASE_SHA}"
  echo "Created ${BRANCH} from ${BASE_REF} (${BASE_SHA})"
  git switch "${BRANCH}"
fi

echo
echo "=== Setup complete ==="
echo "base_ref:  ${BASE_REF}"
echo "base_sha:  ${BASE_SHA}"
echo "tag:       ${TAG_DESC}"
echo "branch:    $(git branch --show-current 2>/dev/null || echo "${BRANCH}")"
git status -sb
echo
echo "Next:"
echo "  1) Ensure docs/upstream-sync/cycles/*-to-${TARGET}.md exists"
echo "  2) Follow docs/upstream-sync/PROCESS.md"
echo "  3) Walk FORK_CHANGES.md features (Fxx)"

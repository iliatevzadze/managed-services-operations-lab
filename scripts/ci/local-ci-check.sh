#!/usr/bin/env bash
# Managed Services Operations Lab — local CI check (Milestone 9)
#
# Mirrors the GitHub Actions checks locally so changes can be validated before
# pushing: Java tests + package, Docker Compose config, image build, shell
# script syntax, and (if available) Kubernetes manifest dry-run.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
cd "${PROJECT_ROOT}"

echo "[CI] 1/6 Java tests (mvn test) ..."
( cd app/spring-support-api && mvn test )

echo "[CI] 2/6 Java package (mvn package -DskipTests) ..."
( cd app/spring-support-api && mvn package -DskipTests )

echo "[CI] 3/6 Docker Compose config ..."
docker compose config >/dev/null

echo "[CI] 4/6 Docker image build ..."
docker build -t msol/spring-support-api:local-ci app/spring-support-api

echo "[CI] 5/6 Shell script syntax checks ..."
bash -n scripts/incidents/*.sh
bash -n scripts/k8s/*.sh
bash -n scripts/sql/*.sh

echo "[CI] 6/6 Kubernetes manifest validation ..."
# --validate=false keeps this client-side only: it validates YAML structure and
# Kubernetes object construction without contacting a cluster API server.
# Full runtime validation is covered by scripts/k8s/deploy-kind.sh.
if command -v kubectl >/dev/null 2>&1; then
  kubectl apply --dry-run=client --validate=false -f k8s/base/
else
  echo "[CI] kubectl not found — skipping Kubernetes manifest validation."
fi

echo
echo "[CI] All local CI checks passed."

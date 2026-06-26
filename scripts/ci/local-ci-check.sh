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
# kubeconform validates manifests against the Kubernetes JSON schemas entirely
# offline. kubectl dry-run is avoided because it can still contact the API
# server for resource discovery when no cluster exists.
# Full runtime validation is covered by scripts/k8s/deploy-kind.sh.
docker run --rm -v "$PWD":/work -w /work \
  ghcr.io/yannh/kubeconform:latest -strict -summary k8s/base
echo "[CI] Kubernetes manifests validated with kubeconform"

echo
echo "[CI] All local CI checks passed."

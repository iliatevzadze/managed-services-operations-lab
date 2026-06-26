#!/usr/bin/env bash
# Managed Services Operations Lab — deploy local Kubernetes lab on kind (Milestone 8)
#
# Builds the API image, creates a kind cluster (if missing), loads the image,
# applies the manifests, and waits for both deployments to become ready.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
cd "${PROJECT_ROOT}"

CLUSTER_NAME="msol"
IMAGE="msol/spring-support-api:local"
NAMESPACE="managed-services-lab"

require() {
  command -v "$1" >/dev/null 2>&1 || { echo "[K8S] ERROR: '$1' not found in PATH."; exit 1; }
}

echo "[K8S] Checking prerequisites (docker, kind, kubectl)..."
require docker
require kind
require kubectl

if ! docker info >/dev/null 2>&1; then
  echo "[K8S] ERROR: Docker daemon is not running."
  exit 1
fi

echo "[K8S] Building image ${IMAGE} from app/spring-support-api ..."
docker build -t "${IMAGE}" app/spring-support-api

if kind get clusters 2>/dev/null | grep -qx "${CLUSTER_NAME}"; then
  echo "[K8S] kind cluster '${CLUSTER_NAME}' already exists — reusing it."
else
  echo "[K8S] Creating kind cluster '${CLUSTER_NAME}' ..."
  kind create cluster --name "${CLUSTER_NAME}" --config k8s/kind/cluster-config.yaml
fi

echo "[K8S] Loading image into kind cluster '${CLUSTER_NAME}' ..."
kind load docker-image "${IMAGE}" --name "${CLUSTER_NAME}"

echo "[K8S] Applying manifests from k8s/base/ ..."
kubectl apply -f k8s/base/

echo "[K8S] Waiting for PostgreSQL rollout ..."
kubectl -n "${NAMESPACE}" rollout status deployment/postgres --timeout=120s

echo "[K8S] Waiting for Spring support API rollout ..."
kubectl -n "${NAMESPACE}" rollout status deployment/spring-support-api --timeout=180s

echo
echo "[K8S] Deployment complete. The API is reachable via the kind port mapping:"
echo "        http://localhost:18082/health"
echo "        http://localhost:18082/tickets"
echo
echo "[K8S] Inspect with: kubectl -n ${NAMESPACE} get pods,svc"

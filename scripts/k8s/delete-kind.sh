#!/usr/bin/env bash
# Managed Services Operations Lab — delete local Kubernetes lab cluster (Milestone 8)
#
# Removes the kind cluster. Safe to run even if the cluster does not exist.

set -euo pipefail

CLUSTER_NAME="msol"

command -v kind >/dev/null 2>&1 || { echo "[K8S] ERROR: 'kind' not found in PATH."; exit 1; }

if kind get clusters 2>/dev/null | grep -qx "${CLUSTER_NAME}"; then
  echo "[K8S] Deleting kind cluster '${CLUSTER_NAME}' ..."
  kind delete cluster --name "${CLUSTER_NAME}"
  echo "[K8S] Cluster '${CLUSTER_NAME}' deleted."
else
  echo "[K8S] kind cluster '${CLUSTER_NAME}' does not exist — nothing to delete."
fi

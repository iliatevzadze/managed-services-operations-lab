#!/usr/bin/env bash
# Managed Services Operations Lab — rollback Spring support API (Milestone 8)
#
# Reverts the spring-support-api Deployment to the previous revision and waits
# for the rollout to complete. Use during a failed-deployment incident.

set -euo pipefail

NAMESPACE="managed-services-lab"
DEPLOYMENT="spring-support-api"

command -v kubectl >/dev/null 2>&1 || { echo "[K8S] ERROR: 'kubectl' not found in PATH."; exit 1; }

echo "[K8S] Current rollout history for ${DEPLOYMENT}:"
kubectl -n "${NAMESPACE}" rollout history deployment/"${DEPLOYMENT}"

# Count revision lines (rows that start with a revision number).
REVISIONS="$(kubectl -n "${NAMESPACE}" rollout history deployment/"${DEPLOYMENT}" \
  | grep -cE '^[0-9]+')"

if [ "${REVISIONS}" -lt 2 ]; then
  echo "[K8S] No previous revision available. Rollback requires at least two deployment revisions."
  exit 0
fi

echo "[K8S] Rolling back ${DEPLOYMENT} to the previous revision ..."
kubectl -n "${NAMESPACE}" rollout undo deployment/"${DEPLOYMENT}"

echo "[K8S] Waiting for rollback to complete ..."
kubectl -n "${NAMESPACE}" rollout status deployment/"${DEPLOYMENT}" --timeout=180s

echo
echo "[K8S] Rollback complete. Validate service health:"
echo "        http://localhost:18082/health"

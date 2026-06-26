#!/usr/bin/env bash
# Managed Services Operations Lab — simulate database down (Milestone 5)
# Stops PostgreSQL to trigger SupportApiDatabaseDown alert path.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

cd "${PROJECT_ROOT}"

echo "[INC-SIM] INC-001 drill: simulating database down"
echo "[INC-SIM] Stopping PostgreSQL container (msol-postgres)..."

docker compose stop postgres

echo "[INC-SIM] Forcing health check to update application metric..."
curl -s http://localhost:18080/health >/dev/null || true
curl -s http://localhost:18081/health >/dev/null || true

echo "[INC-SIM] Waiting 30s for Prometheus scrape interval..."
sleep 30

echo "[INC-SIM] Customer-facing health (Nginx proxy):"
curl -s http://localhost:18081/health || echo "(request failed — expected during drill)"

echo
echo "[INC-SIM] Prometheus: support_api_database_up"
metric_value=$(curl -s 'http://localhost:19090/api/v1/query?query=support_api_database_up' \
  | jq -r '.data.result[0].value[1] // empty' 2>/dev/null || true)

if [[ -z "${metric_value}" || "${metric_value}" == "1" ]]; then
  echo "[INC-SIM] Note: Prometheus may still show the previous sample. Refresh /health and wait for next scrape."
  curl -s 'http://localhost:19090/api/v1/query?query=support_api_database_up' | jq . 2>/dev/null \
    || echo "[INC-SIM] Warning: Prometheus query unavailable — is the stack running?"
else
  echo "[INC-SIM] Metric value: ${metric_value}"
  curl -s 'http://localhost:19090/api/v1/query?query=support_api_database_up' | jq . 2>/dev/null \
    || true
fi

echo
echo "[INC-SIM] Expected alerts:"
echo "  - SupportApiDatabaseDown (critical) — support_api_database_up == 0"
echo "  - /health should show status=DEGRADED, database=DOWN"
echo
echo "[INC-SIM] Restore with: ./scripts/incidents/restore-database-down.sh"
echo "[INC-SIM] Runbook: runbooks/database-down.md"

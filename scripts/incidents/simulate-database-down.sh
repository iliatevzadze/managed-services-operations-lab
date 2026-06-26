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

echo "[INC-SIM] Waiting 10s for health checks and metric scrape..."
sleep 10

echo "[INC-SIM] Customer-facing health (Nginx proxy):"
curl -s http://localhost:18081/health || echo "(request failed — expected during drill)"

echo
echo "[INC-SIM] Prometheus: support_api_database_up"
curl -s 'http://localhost:19090/api/v1/query?query=support_api_database_up' | jq . 2>/dev/null \
  || echo "[INC-SIM] Warning: Prometheus query unavailable — is the stack running?"

echo
echo "[INC-SIM] Expected alerts:"
echo "  - SupportApiDatabaseDown (critical) — support_api_database_up == 0"
echo "  - /health should show status=DEGRADED, database=DOWN"
echo
echo "[INC-SIM] Restore with: ./scripts/incidents/restore-database-down.sh"
echo "[INC-SIM] Runbook: runbooks/database-down.md"

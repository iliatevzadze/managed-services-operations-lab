#!/usr/bin/env bash
# Managed Services Operations Lab — restore database down simulation (Milestone 5)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

cd "${PROJECT_ROOT}"

echo "[INC-SIM] Restoring PostgreSQL after INC-001 drill..."

docker compose start postgres

echo "[INC-SIM] Waiting 15s for postgres health check and API recovery..."
sleep 15

echo "[INC-SIM] Customer-facing health (Nginx proxy):"
curl -s http://localhost:18081/health | jq .

echo
echo "[INC-SIM] Prometheus: support_api_database_up"
curl -s 'http://localhost:19090/api/v1/query?query=support_api_database_up' | jq . 2>/dev/null \
  || echo "[INC-SIM] Warning: Prometheus query unavailable"

echo
echo "[INC-SIM] Expected: status=UP, database=UP, support_api_database_up=1"
echo "[INC-SIM] Confirm alerts return to inactive at http://localhost:19090/alerts"

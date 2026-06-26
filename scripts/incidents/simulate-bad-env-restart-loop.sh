#!/usr/bin/env bash
# Managed Services Operations Lab — simulate bad env / restart loop (Milestone 5)
# Applies incident-only Compose override with wrong database URL.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

cd "${PROJECT_ROOT}"

echo "[INC-SIM] INC-003 drill: simulating bad deployment / broken environment config"
echo "[INC-SIM] Warning: run restore-bad-env-restart-loop.sh before starting another incident."
echo "[INC-SIM] Applying docker-compose.incident-bad-env.yml (wrong database: wrongdb)..."

docker compose -f docker-compose.yml -f docker-compose.incident-bad-env.yml up -d --force-recreate spring-support-api

echo "[INC-SIM] Waiting 20s for container health check cycles..."
sleep 20

echo "[INC-SIM] Container status:"
docker compose ps

echo
echo "[INC-SIM] Recent spring-support-api logs:"
docker compose logs --tail=40 spring-support-api

echo
echo "[INC-SIM] Customer-facing health (Nginx proxy):"
curl -s http://localhost:18081/health || echo "(request failed or DEGRADED — expected during drill)"

echo
echo "[INC-SIM] Expected impact:"
echo "  - msol-support-api unhealthy or restarting (health check fails on bad DB)"
echo "  - support_api_database_up = 0"
echo "  - SupportApiDatabaseDown (critical) may fire"
echo "  - Customer requests via Nginx may fail or return errors"
echo
echo "[INC-SIM] Restore with: ./scripts/incidents/restore-bad-env-restart-loop.sh"
echo "[INC-SIM] Runbooks: runbooks/container-restart.md, runbooks/failed-deployment.md"

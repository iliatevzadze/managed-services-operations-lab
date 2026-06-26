#!/usr/bin/env bash
# Managed Services Operations Lab — restore bad env / restart loop simulation (Milestone 5)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

cd "${PROJECT_ROOT}"

echo "[INC-SIM] Restoring spring-support-api after INC-003 drill..."
echo "[INC-SIM] Recreating container with normal docker-compose.yml configuration..."

docker compose -f docker-compose.yml up -d --force-recreate spring-support-api

echo "[INC-SIM] Waiting 30s for healthy startup..."
sleep 30

echo "[INC-SIM] Container status:"
docker compose ps

echo
echo "[INC-SIM] Customer-facing health (Nginx proxy):"
curl -s http://localhost:18081/health | jq .

echo
echo "[INC-SIM] Expected: msol-support-api healthy, status=UP, database=UP"
echo "[INC-SIM] Document resolution in incidents/INC-003-container-restart-loop.md"

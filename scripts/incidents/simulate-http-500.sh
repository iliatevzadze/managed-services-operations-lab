#!/usr/bin/env bash
# Managed Services Operations Lab — simulate HTTP 500 errors (Milestone 5)
# Triggers SupportApiHighErrorRate alert path via /simulate/http-500.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

cd "${PROJECT_ROOT}"

echo "[INC-SIM] INC-002 drill: simulating HTTP 500 errors"
echo "[INC-SIM] Sending 10 requests to http://localhost:18081/simulate/http-500"

for i in $(seq 1 10); do
  code=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:18081/simulate/http-500 || echo "000")
  echo "  request ${i}: HTTP ${code}"
done

echo
echo "[INC-SIM] Waiting 5s for metrics scrape..."
sleep 5

echo "[INC-SIM] Prometheus: HTTP 5xx rate (2m window)"
curl -s 'http://localhost:19090/api/v1/query?query=sum(rate(http_server_requests_seconds_count{job="spring-support-api",status=~"5.."}[2m]))' | jq . 2>/dev/null \
  || echo "[INC-SIM] Warning: Prometheus query unavailable — is the stack running?"

echo
echo "[INC-SIM] Expected alert: SupportApiHighErrorRate (warning)"
echo "[INC-SIM] Alert may show pending for 2m before firing — check http://localhost:19090/alerts"
echo "[INC-SIM] Runbook: runbooks/application-500-errors.md"

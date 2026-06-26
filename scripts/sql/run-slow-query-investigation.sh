#!/usr/bin/env bash
# Managed Services Operations Lab — slow SQL query investigation (Milestone 6)
# Runs EXPLAIN ANALYZE before/after index fix and saves evidence files.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
SQL_DIR="${PROJECT_ROOT}/database/sql-troubleshooting"
EVIDENCE_DIR="${SQL_DIR}/evidence"

cd "${PROJECT_ROOT}"

if ! docker compose ps postgres 2>/dev/null | grep -qE 'running|healthy'; then
    echo "[SQL-INV] ERROR: Docker Compose stack is not running. Start with: docker compose up -d"
    exit 1
fi

mkdir -p "${EVIDENCE_DIR}"

run_sql_file() {
    local file="$1"
    docker compose exec -T postgres psql -U supportuser -d supportdb -v ON_ERROR_STOP=1 \
        < "${file}"
}

echo "[SQL-INV] Milestone 6: slow ticket history search investigation"
echo "[SQL-INV] Target: support_ticket_events on msol-postgres (supportdb)"
echo

echo "[SQL-INV] Step 1/4 — create demo table and seed ~100,000 rows..."
run_sql_file "${SQL_DIR}/01-create-slow-query-demo.sql"

echo
echo "[SQL-INV] Step 2/4 — EXPLAIN ANALYZE before index..."
run_sql_file "${SQL_DIR}/02-before-index-explain.sql" | tee "${EVIDENCE_DIR}/before-index-explain.txt"

echo
echo "[SQL-INV] Step 3/4 — apply composite index (CHG-001 lab validation)..."
run_sql_file "${SQL_DIR}/03-add-index.sql"

echo
echo "[SQL-INV] Step 4/4 — EXPLAIN ANALYZE after index..."
run_sql_file "${SQL_DIR}/04-after-index-explain.sql" | tee "${EVIDENCE_DIR}/after-index-explain.txt"

echo
echo "================================================================"
echo "[SQL-INV] INVESTIGATION SUMMARY"
echo "================================================================"
echo "Issue:          Customer reports slow ticket history search"
echo "Customer:       Summit Financial"
echo "Filter:         event_type = STATUS_CHANGE, last 30 days"
echo "Suspected cause: Missing composite index → sequential scan"
echo
echo "Before evidence: ${EVIDENCE_DIR}/before-index-explain.txt"
echo "Change applied:  idx_support_ticket_events_customer_event_created"
echo "                 ON (customer_name, event_type, created_at DESC)"
echo "After evidence:  ${EVIDENCE_DIR}/after-index-explain.txt"
echo
echo "Related problem: problem-records/PRB-001-recurring-database-timeout.md"
echo "Related change:  changes/CHG-001-add-sql-index.md"
echo "Runbook:         runbooks/slow-sql-query.md"
echo
echo "Cleanup (optional): docker compose exec -T postgres psql -U supportuser -d supportdb \\"
echo "  < database/sql-troubleshooting/05-cleanup-slow-query-demo.sql"
echo "================================================================"

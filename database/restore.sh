#!/usr/bin/env bash
# Managed Services Operations Lab — Database restore (Milestone 2)
# Restores a logical backup into the support database via Docker Compose.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

DB_NAME="supportdb"
DB_USER="supportuser"
SERVICE="postgres"

if [[ $# -ne 1 ]]; then
    echo "[restore] ERROR: missing backup file argument." >&2
    echo "Usage: $0 <path-to-backup.sql>" >&2
    exit 1
fi

BACKUP_FILE="$1"

if [[ ! -f "${BACKUP_FILE}" ]]; then
    echo "[restore] ERROR: backup file not found: ${BACKUP_FILE}" >&2
    exit 1
fi

echo "[restore] WARNING: this will apply '${BACKUP_FILE}' to database '${DB_NAME}'."
echo "[restore] Existing data may be overwritten. Ensure the application is stopped or quiesced."

cd "${PROJECT_ROOT}"
docker compose exec -T "${SERVICE}" psql -U "${DB_USER}" -d "${DB_NAME}" < "${BACKUP_FILE}"

echo "[restore] Done. Database '${DB_NAME}' restored from ${BACKUP_FILE}."

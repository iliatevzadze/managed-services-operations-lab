#!/usr/bin/env bash
# Managed Services Operations Lab — Database backup (Milestone 2)
# Creates a timestamped logical backup of the support database via Docker Compose.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
BACKUP_DIR="${SCRIPT_DIR}/backups"

DB_NAME="supportdb"
DB_USER="supportuser"
SERVICE="postgres"

TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_FILE="${BACKUP_DIR}/supportdb-${TIMESTAMP}.sql"

mkdir -p "${BACKUP_DIR}"

echo "[backup] Creating backup of database '${DB_NAME}'..."

cd "${PROJECT_ROOT}"
docker compose exec -T "${SERVICE}" pg_dump -U "${DB_USER}" "${DB_NAME}" > "${BACKUP_FILE}"

echo "[backup] Done. Backup written to:"
echo "         ${BACKUP_FILE}"

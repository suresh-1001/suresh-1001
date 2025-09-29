#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p backups
STAMP=$(date +%Y%m%d_%H%M%S)
OUT="backups/wpdb_${STAMP}.sql"
echo "[*] Dumping DB to $OUT"
docker compose exec -T mariadb mariadb-dump \
  -u"${MARIADB_USER}" -p"${MARIADB_PASSWORD}" "${MARIADB_DATABASE}" > "$OUT"
ln -sf "$OUT" backups/latest.sql
echo "[✓] Done."

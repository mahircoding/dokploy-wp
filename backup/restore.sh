#!/bin/bash

set -euo pipefail

# Path to the mounted backup volume.
BACKUP_DIR="${BACKUP_DIR:-/backup}"

DB_HOST="${DB_HOST:-db}"
DB_USER="${DB_USER:-wordpress}"
DB_PASSWORD="${DB_PASSWORD:-wordpress}"
DB_NAME="${DB_NAME:-wordpress}"
WP_ROOT="${WP_ROOT:-/var/www/html}"

# Optional: pick a specific file, otherwise use the most recent snapshot.
DB_DUMP="${1:-$BACKUP_DIR/db-*.sql}"
WP_BUNDLE="${2:-$BACKUP_DIR/wp-content-*.tar.gz}"

echo "Restoring database $DB_NAME@$DB_HOST from $DB_DUMP ..."
mysql -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" < "$DB_DUMP"

echo "Restoring wp-content from $WP_BUNDLE ..."
tar -xzf "$WP_BUNDLE" -C "$WP_ROOT"

echo "Restore complete."
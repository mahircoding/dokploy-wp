#!/bin/bash

set -euo pipefail

# Path to the mounted backup volume.
BACKUP_DIR="${BACKUP_DIR:-/backup}"
mkdir -p "$BACKUP_DIR"

# Allow override for use outside the container (e.g. running on the host).
DB_HOST="${DB_HOST:-db}"
DB_USER="${DB_USER:-wordpress}"
DB_PASSWORD="${DB_PASSWORD:-wordpress}"
DB_NAME="${DB_NAME:-wordpress}"

# WordPress install root.
WP_ROOT="${WP_ROOT:-/var/www/html}"

if [ ! -d "$WP_ROOT" ]; then
    echo "Error: WordPress root not found: $WP_ROOT" >&2
    exit 1
fi

STAMP="$(date +%Y%m%d-%H%M%S)"

echo "Dumping database $DB_NAME@$DB_HOST to $BACKUP_DIR/db-$STAMP.sql ..."
mysqldump \
    -h"$DB_HOST" \
    -u"$DB_USER" \
    -p"$DB_PASSWORD" \
    --single-transaction \
    --no-tablespaces \
    "$DB_NAME" \
    > "$BACKUP_DIR/db-$STAMP.sql"

echo "Archiving wp-content to $BACKUP_DIR/wp-content-$STAMP.tar.gz ..."
# Run tar from the WordPress root so the archive stores relative paths (wp-content/...).
tar -czf "$BACKUP_DIR/wp-content-$STAMP.tar.gz" \
    --exclude='*.log' \
    -C "$WP_ROOT" wp-content

echo "Backup complete:"
ls -lh "$BACKUP_DIR"/db-$STAMP.sql "$BACKUP_DIR"/wp-content-$STAMP.tar.gz
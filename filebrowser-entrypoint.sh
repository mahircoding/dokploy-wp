#!/bin/sh
set -eu

DB_FILE="/database/filebrowser.db"
mkdir -p /database

if [ ! -f "$DB_FILE" ]; then
  echo "Initializing FileBrowser database..."
  /filebrowser --database "$DB_FILE" --root /srv config init >/dev/null 2>&1 || true
fi

if [ -f "$DB_FILE" ]; then
  echo "Ensuring FileBrowser user exists..."
  /filebrowser users add "${FB_USERNAME:-admin}" "${FB_PASSWORD:-admin}" --perm.admin --database "$DB_FILE" >/dev/null 2>&1 || true
fi

exec /filebrowser --port 80 --database "$DB_FILE" --root /srv "$@"

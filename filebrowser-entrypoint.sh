#!/bin/sh
set -eu

DB_FILE="/database/filebrowser.db"
mkdir -p /database

FB_BIN=""
for candidate in /usr/bin/filebrowser /usr/local/bin/filebrowser /filebrowser; do
  if [ -x "$candidate" ]; then
    FB_BIN="$candidate"
    break
  fi
done

if [ -z "$FB_BIN" ]; then
  echo "FileBrowser binary not found" >&2
  exit 1
fi

if [ ! -f "$DB_FILE" ]; then
  echo "Initializing FileBrowser database..."
  "$FB_BIN" --database "$DB_FILE" --root /srv config init >/dev/null 2>&1 || true
fi

if [ -f "$DB_FILE" ]; then
  echo "Ensuring FileBrowser user exists..."
  "$FB_BIN" users add "${FB_USERNAME:-admin}" "${FB_PASSWORD:-admin}" --perm.admin --database "$DB_FILE" >/dev/null 2>&1 || true
fi

exec "$FB_BIN" --port 80 --database "$DB_FILE" --root /srv "$@"

#!/bin/bash

set -euo pipefail

# Wait for MariaDB to be reachable before doing anything.
until mysqladmin ping -h"${DB_HOST:-db}" -u"${DB_USER:-wordpress}" -p"${DB_PASSWORD:-wordpress}" --silent; do
    echo "Waiting for MariaDB at ${DB_HOST}..."
    sleep 2
done
echo "MariaDB is ready."

mkdir -p /var/www/html
cd /var/www/html

# WordPress core download (idempotent / safe if interrupted).
if [ ! -f wp-load.php ] && [ ! -f wp-settings.php ]; then
    echo "Downloading WordPress..."
    if ! wp core download --allow-root; then
        echo "WordPress download failed; continuing so PHP-FPM can still start."
    fi
fi

# Configure WordPress if not yet configured.
if [ ! -f wp-config.php ] && [ -f wp-load.php ]; then
    echo "Creating wp-config.php..."
    if ! wp config create \
        --dbname="${DB_NAME:-wordpress}" \
        --dbuser="${DB_USER:-wordpress}" \
        --dbpass="${DB_PASSWORD:-wordpress}" \
        --dbhost="${DB_HOST:-db}" \
        --allow-root; then
        echo "WordPress config creation failed; continuing so PHP-FPM can still start."
    fi
fi

# Run the install routine if it hasn't run yet.
if [ -f wp-load.php ] && ! wp core is-installed --allow-root 2>/dev/null; then
    echo "Installing WordPress..."
    if ! wp core install \
        --url="${WP_URL:-${DOMAIN:-localhost}}" \
        --title="${WP_TITLE:-My Website}" \
        --admin_user="${WP_USER:-admin}" \
        --admin_password="${WP_PASSWORD:-admin}" \
        --admin_email="${WP_EMAIL:-admin@example.com}" \
        --skip-email \
        --allow-root; then
        echo "WordPress install failed; continuing so PHP-FPM can still start."
    fi
elif [ -f wp-load.php ]; then
    echo "WordPress already installed."
fi

# fix ownership so the FPM worker can write (uploads, cache, plugins)
chown -R www-data:www-data /var/www/html || true

# If WordPress core is still not available, serve a temporary page instead of a blank 404.
if [ ! -f /var/www/html/wp-load.php ] && [ ! -f /var/www/html/index.php ]; then
    cat > /var/www/html/index.php <<'PHP'
<?php
header('Content-Type: text/html; charset=utf-8');
echo '<h1>WordPress is still installing</h1>';
echo '<p>Please wait a moment while the container finishes setup.</p>';
PHP
fi

exec "$@"
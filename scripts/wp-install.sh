#!/bin/bash

set -euo pipefail

cd /var/www/html

if [ ! -f wp-config.php ]; then
    echo "Downloading WordPress..."
    wp core download --allow-root

    echo "Creating wp-config.php..."
    wp config create \
        --dbname="${DB_NAME:-wordpress}" \
        --dbuser="${DB_USER:-wordpress}" \
        --dbpass="${DB_PASSWORD:-wordpress}" \
        --dbhost="${DB_HOST:-db}" \
        --allow-root
fi

# Only run core install if not already installed (safe to re-run).
if ! wp core is-installed --allow-root 2>/dev/null; then
    echo "Installing WordPress..."
    wp core install \
        --url="${WP_URL:-${DOMAIN:-localhost}}" \
        --title="${WP_TITLE:-My Website}" \
        --admin_user="${WP_USER:-admin}" \
        --admin_password="${WP_PASSWORD:-admin}" \
        --admin_email="${WP_EMAIL:-admin@example.com}" \
        --skip-email \
        --allow-root
else
    echo "WordPress already installed."
fi
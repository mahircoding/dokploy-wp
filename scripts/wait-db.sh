#!/bin/sh

echo "Waiting MariaDB..."

until mysqladmin ping \
    -h"${DB_HOST:-db}" \
    -u"${DB_USER:-wordpress}" \
    -p"${DB_PASSWORD:-wordpress}" \
    --silent 2>/dev/null

do
    sleep 2
done

echo "MariaDB Ready"
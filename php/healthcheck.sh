#!/bin/sh

php -v || exit 1

php-fpm -t || exit 1

exit 0
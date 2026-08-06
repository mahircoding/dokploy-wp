# Dokploy WordPress Hosting

Production-ready WordPress stack built for **Dokploy Compose**.

## Stack

| Service      | Image / Build                        | Notes                                    |
|--------------|--------------------------------------|------------------------------------------|
| Nginx        | `nginx:1.28-alpine` (custom)         | front proxy, static cache, security      |
| WordPress    | `php:8.4-fpm-bookworm` (custom)      | auto-install on first boot, WP-CLI       |
| MariaDB      | `mariadb:11.8`                       | persistent volume                        |
| Redis        | `redis:8-alpine`                     | object cache target, password protected  |
| Adminer      | `adminer:latest`                     | DB management (internal)                 |
| FileBrowser  | `filebrowser/filebrowser:latest`     | file manager over wp-content             |

## Quick start

```bash
cp .env.example .env
# 1. Edit .env — passwords, domain, WordPress credentials
# 2. Deploy via Dokploy using "Compose" pointing at this repository, or:
docker compose up -d --build
```

On first boot the `wordpress` container downloads WordPress, creates
`wp-config.php` from the `.env` values, and runs `wp core install` with the
credentials you set (`WP_USER` / `WP_PASSWORD` / `WP_EMAIL`). Subsequent
starts are no-ops — nothing is overwritten.

## Access

- WordPress site: the port exposed by the `nginx` service (80). In Dokploy,
  wire the domain through its proxy to this port.
- Adminer: port of the `adminer` service (log in with `DB_USER` / `DB_PASSWORD`,
  server `mariadb`).
- FileBrowser: port of the `filebrowser` service.

> For a single public entrypoint, expose only Nginx and let Dokploy route the
> rest through its reverse proxy — or publish adminer/filebrowser only on
> internal/`localhost`.

## Configuration (`.env`)

| Variable          | Default        | Purpose                              |
|-------------------|----------------|--------------------------------------|
| `DOMAIN`          | `example.com`  | used when `WP_URL` is unset          |
| `WP_URL`          | `$DOMAIN`      | public URL for `wp core install`     |
| `WP_TITLE`        | `My Website`   | site title                           |
| `WP_USER`         | `admin`        | admin username                       |
| `WP_PASSWORD`     | —              | admin password (change before deploy)|
| `WP_EMAIL`        | —              | admin email                          |
| `PHP_VERSION`     | `8.4`          | PHP-FPM version                      |
| `DB_NAME`         | `wordpress`    | database name                        |
| `DB_USER`         | `wordpress`    | database user                        |
| `DB_PASSWORD`     | —              | database password                    |
| `DB_ROOT_PASSWORD`| —              | MariaDB root password                |
| `DB_HOST`         | `mariadb`      | internal service name (keep)         |
| `REDIS_PASSWORD`  | —              | Redis requirepass                    |
| `REDIS_HOST`      | `redis`        | internal service name (keep)         |
| `TZ`              | `Asia/Jakarta` | timezone                             |

## WordPress CLI

`wp` is installed in the `wordpress` container:

```bash
docker compose exec wordpress wp plugin install redis-cache --activate --allow-root
docker compose exec wordpress wp plugin activate redis-cache --allow-root
docker compose exec wordpress wp redis enable --allow-root   # if the plugin provides it
```

## Backups

The `./backup` directory is mounted at `/backup` in the `wordpress` container.
Run inside the container:

```bash
docker compose exec wordpress /backup/backup.sh
```

Creates timestamped `db-<ts>.sql` + `wp-content-<ts>.tar.gz` in `./backup`.
Restore the latest snapshot:

```bash
docker compose exec wordpress /backup/restore.sh
```

## Healthchecks

Nginx, WordPress (php-fpm), MariaDB, and Redis all expose Docker healthchecks;
Nginx and WordPress containers wait for their dependencies to become healthy
before starting (`condition: service_healthy`), which prevents the classic
"connection refused to MariaDB" race on first boot.

## Notes

- Passwords are interpolated from `.env`; if you reuse this repo elsewhere,
  rotate every password before going live.
- `xmlrpc.php` still runs (some plugins need it). If you don't use XML-RPC,
  delete the matching location in `nginx/default.conf`.
- The static-file location only caches non-executable assets; PHP inside
  `wp-content/uploads` is always denied.

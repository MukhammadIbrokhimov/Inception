# Inception (Docker web stack)

This repository defines a small web stack using Docker Compose:

- **Nginx**: TLS terminator + reverse proxy (public entrypoint on `:443`)
- **WordPress**: application container (HTTP on `:80`, published as `localhost:8080` for debugging)
- **MariaDB**: database container (published as `localhost:3306` for debugging)

The “public APIs” of this repo are its **Make targets**, **Docker Compose services**, and **configuration files** (env vars + Nginx config).

## Quickstart

### Prerequisites

- **Docker Engine** (includes `docker`)
- **Docker Compose** (either `docker compose` v2 or legacy `docker-compose`)
- **make**

### Configure environment

Create a `srcs/.env` file with your database settings (this repo ships with an empty `srcs/.env`).

Minimum required variables used by `srcs/docker-compose.yml`:

```bash
# srcs/.env
DB_ROOT_PASSWORD=change-me
DB_NAME=wordpress
DB_USER=wordpress
DB_PASSWORD=change-me-too
```

Notes:

- **Do not commit secrets**. If you use `secrets/`, treat it as local-only unless your project explicitly requires it.
- WordPress uses these values via `WORDPRESS_DB_*` environment variables.

### Start the stack

From the repository root:

```bash
make build
```

Or start without rebuilding:

```bash
make start
```

### Access

- **Nginx (HTTPS)**: `https://localhost` (port **443**)
  - Uses a **self-signed** certificate by default.
- **WordPress (HTTP debug)**: `http://localhost:8080`
- **MariaDB (TCP debug)**: `localhost:3306`

## Public interface reference (APIs / functions / components)

### Make targets (public “functions”)

The `Makefile` is the primary command surface. All targets call Docker Compose with `-f srcs/docker-compose.yml`.

- **`make build`**: Build images (Nginx) and start all services.

```bash
make build
```

- **`make start`**: Start all services (no forced rebuild).

```bash
make start
```

- **`make stop`**: Stop and remove containers (keeps named volumes).

```bash
make stop
```

- **`make restart`**: Restart services.

```bash
make restart
```

- **`make ps`**: Show container status.

```bash
make ps
```

- **`make logs`**: Tail service logs.

```bash
make logs
```

- **`make rm`**: Remove stopped service containers (interactive prompts may appear depending on your Compose version).

```bash
make rm
```

### Docker Compose “components” (services)

Defined in `srcs/docker-compose.yml`.

#### `web` (Nginx)

- **Name**: `web` (container name `nginx-server`)
- **Build**: `srcs/requirements/nginx/Dockerfile`
- **Ports**:
  - `443:443` (public HTTPS)
- **Config mount**:
  - `srcs/requirements/nginx/conf` → `/etc/nginx/conf.d`
- **Network**:
  - `app-network`
- **Role**:
  - Terminates TLS and proxies requests to WordPress at `http://wordpress:80`

Relevant configuration files:

- `srcs/requirements/nginx/conf/nginx.conf`: Nginx global config and `include /etc/nginx/conf.d/*.conf;`
- `srcs/requirements/nginx/conf/default.conf`: HTTPS server block and proxy routing
- `srcs/requirements/nginx/Dockerfile`: generates a self-signed cert at `/etc/nginx/ssl/*`

#### `wordpress`

- **Image**: `wordpress:6.5`
- **Ports**:
  - `8080:80` (debug / direct access)
- **Volume**:
  - `wordpress:/var/www/html` (named volume)
- **Environment**:
  - `WORDPRESS_DB_HOST=mariadb:3306`
  - `WORDPRESS_DB_USER=${DB_USER}`
  - `WORDPRESS_DB_PASSWORD=${DB_PASSWORD}`
  - `WORDPRESS_DB_NAME=${DB_NAME}`
- **Healthcheck**:
  - `curl -f http://localhost`

#### `mariadb`

- **Image**: `mariadb:11.1`
- **Ports**:
  - `3306:3306` (debug / direct access)
- **Volume**:
  - `mariadb:/var/lib/mysql` (named volume)
- **Environment**:
  - `MYSQL_ROOT_PASSWORD=${DB_ROOT_PASSWORD}`
  - `MYSQL_DATABASE=${DB_NAME}`
  - `MYSQL_USER=${DB_USER}`
  - `MYSQL_PASSWORD=${DB_PASSWORD}`
- **Healthcheck**:
  - `mysqladmin ping ...`

### Configuration “APIs”

#### Environment variables (`srcs/.env`)

These variables are referenced by `srcs/docker-compose.yml` and are required for MariaDB/WordPress boot:

- **`DB_ROOT_PASSWORD`**: MariaDB root password (used by `MYSQL_ROOT_PASSWORD`)
- **`DB_NAME`**: database name (used by `MYSQL_DATABASE` and `WORDPRESS_DB_NAME`)
- **`DB_USER`**: database user (used by `MYSQL_USER` and `WORDPRESS_DB_USER`)
- **`DB_PASSWORD`**: database user password (used by `MYSQL_PASSWORD` and `WORDPRESS_DB_PASSWORD`)

#### Ports

- **443/tcp**: Nginx HTTPS (primary public entrypoint)
- **8080/tcp**: WordPress HTTP (debug; bypasses Nginx)
- **3306/tcp**: MariaDB (debug/admin access)

#### Volumes (data persistence)

Named volumes are declared in `srcs/docker-compose.yml`:

- **`mariadb`**: persisted DB files at `/var/lib/mysql`
- **`wordpress`**: persisted WordPress files at `/var/www/html`

Examples:

```bash
# List volumes
docker volume ls

# Inspect a volume
docker volume inspect mariadb
```

#### Networking

All services join the **`app-network`** bridge network.

Service-to-service DNS names inside the network:

- `mariadb` (MariaDB)
- `wordpress` (WordPress)
- `web` (Nginx service name; container is `nginx-server`)

## Usage examples

### View logs for a specific service

```bash
docker compose -f srcs/docker-compose.yml logs -f web
docker compose -f srcs/docker-compose.yml logs -f wordpress
docker compose -f srcs/docker-compose.yml logs -f mariadb
```

### Open a shell in a running container

```bash
docker compose -f srcs/docker-compose.yml exec web sh
docker compose -f srcs/docker-compose.yml exec mariadb sh
docker compose -f srcs/docker-compose.yml exec wordpress sh
```

### Connect to MariaDB from your host

```bash
mysql -h 127.0.0.1 -P 3306 -u "${DB_USER}" -p
```

### Reset the stack (containers only)

```bash
make stop
```

If you also want to delete persisted data, remove the volumes explicitly:

```bash
docker volume rm mariadb wordpress
```

## TLS / certificates

By default, the Nginx image generates a **self-signed** certificate at:

- `/etc/nginx/ssl/certificate.crt`
- `/etc/nginx/ssl/private.key`

To use a real certificate, mount your cert/key into `/etc/nginx/ssl` and keep `default.conf` pointing to those paths.

## Repository layout

- `Makefile`: public command surface
- `srcs/docker-compose.yml`: service definitions, networks, volumes
- `srcs/.env`: runtime configuration (not committed with real secrets)
- `srcs/requirements/nginx/`: Nginx image + config
- `srcs/requirements/mariadb/`: MariaDB Dockerfile (currently not used by Compose)
- `srcs/requirements/wordpress/`: WordPress Dockerfile (currently not used by Compose)

## Troubleshooting

- **HTTPS shows certificate warning**: expected with a self-signed cert; proceed or install a trusted cert.
- **WordPress can’t connect to DB**:
  - ensure `srcs/.env` is populated
  - check MariaDB health: `docker compose -f srcs/docker-compose.yml ps`
  - inspect logs: `docker compose -f srcs/docker-compose.yml logs mariadb`
- **Port already in use**:
  - change host port mappings in `srcs/docker-compose.yml` (e.g. `443:443`, `8080:80`, `3306:3306`)


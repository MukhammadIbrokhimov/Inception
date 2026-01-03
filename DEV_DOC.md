# Inception Project - Developer Documentation

This document provides technical details, architectural overview, and development workflows for the Inception Docker project.

## 📋 Table of Contents

1. [Project Architecture](#project-architecture)
2. [Prerequisites](#prerequisites)
3. [Environment Setup](#environment-setup)
4. [Build and Launch Process](#build-and-launch-process)
5. [Container Management](#container-management)
6. [Volume Management](#volume-management)
7. [Development Workflow](#development-workflow)
8. [Technical Specifications](#technical-specifications)
9. [Troubleshooting](#troubleshooting)

---

## 🏗 Project Architecture

The project implements a microservices architecture using Docker containers. Each service runs in a separate container, communicating via a dedicated Docker bridge network.

### High-Level Overview

- **NGINX**: Acts as the border gateway. It handles TLS termination and proxies requests to WordPress.
- **WordPress**: The application layer. It processes PHP requests via PHP-FPM and communicates with the database.
- **MariaDB**: The data persistence layer. It stores the WordPress application data.

### Communication Flow

1. Client (Browser) -> HTTPS (443) -> **NGINX**
2. **NGINX** -> FastCGI (9000) -> **WordPress** (PHP-FPM)
3. **WordPress** -> TCP (3306) -> **MariaDB**

### Network Topology

```
           [Host Machine]
                 |
      (Port 443:443 mapped)
                 |
        +--------v--------+
        |      NGINX      |
        |  (alpine:3.23)  |
        +--------+--------+
                 |
      [ inception-network ]
                 |
        +--------v--------+             +-----------------+
        |    WordPress    +------------>|     MariaDB     |
        |  (alpine:3.23)  |  TCP:3306   |  (alpine:3.23)  |
        +-----------------+             +-----------------+
```

---

## 🛑 Prerequisites

Ensure your development environment has the following software installed:

- **Docker Engine**: v20.10.x or newer
- **Docker Compose**: v2.x or newer
- **Make**: GNU Make 4.x
- **OS**: Linux (recommended) or macOS

### Initial Setup

Map the project domain to localhost in your `/etc/hosts` file:

```bash
# Add this line to /etc/hosts
127.0.0.1       mukibrok.42.fr
::1       mukibrok.42.fr
```

---

## ⚙️ Environment Setup

### 1. Clone the Repository

```bash
git clone <repository-url> inception
cd inception
```

### 2. Configure Environment Variables

The `.env` file is located in `srcs/.env` and drives the configuration of all services.

**Required Variables**:

```ini
DOMAIN_NAME=mukibrok.42.fr
# Database credentials
DB_NAME=wordpress
DB_USER=user
# WordPress Admin
WP_ADMIN_USER=admin
WP_ADMIN_EMAIL=admin@student.42.fr
WP_TITLE=Inception
WP_URL=https://mukibrok.42.fr
```

### 3. Setup Secrets

The project uses Docker Secrets for secure password management.
You can automatically create the secrets directory and files using the Makefile:

```bash
make secrets
```

*Note: Ensure `secrets/` is added to `.gitignore`.*

### 4. Create Data Directories

Data directories for volumes are automatically created by the Makefile during the build process.
The `make` command will create them at `$(pwd)/data/`.

*(No manual action required)*

---

## 🚀 Build and Launch Process

### Makefile Targets

The `Makefile` simplifies common Docker Compose operations.

| Target | Command | Description |
| :--- | :--- | :--- |
| `make` | `docker compose up --build` | Builds images and starts all containers. |
| `make start` | `docker compose up` | Starts existing containers. |
| `make stop` | `docker compose down` | Stops and removes containers/networks. |
| `make restart` | `docker compose restart` | Restarts all containers. |
| `make rm` | `docker compose rm` | Removes stopped service containers. |
| `make ps` | `docker compose ps` | Lists running containers. |
| `make logs` | `docker compose logs` | Streams logs from all containers. |
| `make secrets` | `mkdir ...` | Generates secrets for development. |
| `make delete` | `rm -rf secrets` | Removes secret files. |
| `make clean` | `... down --volumes` + prune | **Destructive**: Removes all containers, images, volumes, networks, and data. |

### Build Workflow

When you run `make`:

1. **Build**: Docker builds images for `nginx`, `wordpress`, and `mariadb` using local Dockerfiles.
2. **Network**: Creates `inception-network`.
3. **Volumes**: Mounts host directories to container volumes.
4. **Start**: Containers start in dependency order (MariaDB -> WordPress -> NGINX).

---

## 📦 Container Management

### Inspecting Containers

Check resource usage and status:

```bash
docker stats
```

### Accessing Shells

To debug a specific container, execute an interactive shell:

**NGINX**:

```bash
docker exec -it nginx bash
```

**WordPress**:

```bash
docker exec -it wordpress bash
```

**MariaDB**:

```bash
docker exec -it mariadb sh
```

### Rebuilding a Single Service

If you modify code for just one service (e.g., WordPress), rebuild only that service to save time:

```bash
docker compose -f srcs/docker-compose.yml up -d --build wordpress
```

---

## 💾 Volume Management

Data persistence is handled via bind mounts to the host system.

- **WordPress Volume**: `wordpress` -> `${VOL_PATH}/wordpress`
  - Stores: Web files (`/var/www/html`)
- **MariaDB Volume**: `mariadb` -> `${VOL_PATH}/mariadb`
  - Stores: Database files (`/var/lib/mysql`)

**Customizing Volume Paths**:
The default volume path is set to `$(pwd)/data` in the `Makefile`.
To change the location of your data volumes, modify the `VOL_PATH` variable at the top of the `Makefile`:

```makefile
VOL_PATH=/path/to/your/custom/data/dir
```

### Cleaning Volumes

To completely reset the project (delete the database and WP installation):

```bash
make clean
# Automatically runs: sudo rm -rf /Users/muxammad/Desktop/Inception/data/*
```

---

## 👨‍💻 Development Workflow

1. **Modify Configuration**:
    - Edit `srcs/requirements/nginx/conf/nginx.conf` for NGINX config changes.
    - Edit `srcs/requirements/wordpress/conf/www.conf` (via Dockerfile sed) or `entrypoint.sh` for PHP settings.
2. **Apply Changes**:
    - Run `make` to rebuild affected containers.
3. **Verify**:
    - Check logs: `make logs`
    - Visit `https://mukibrok.42.fr`
4. **Debug**:
    - If a service fails, use `docker logs <container_name>` to see specific error messages.

### Best Practices

- **Atomic Changes**: Change one service at a time and verify.
- **Secrets**: Always use Docker secrets; never hardcode passwords in Dockerfiles.
- **PID 1**: Ensure entrypoint scripts use `exec "$@"` or run the main process in the foreground to handle signals correctly.

---

## 🔧 Technical Specifications

### Base Images

- **Distro**: `alpine:3.23` (Lightweight, secure)
  - Used for all containers to minimize footprint.

### NGINX Configuration

- **Security**: TLS v1.2/v1.3 only.
- **Certificates**: Self-signed, generated at build time via OpenSSL.
- **Ports**: Exposes 443 only.

### WordPress (PHP-FPM)

- **Version**: Latest tarball download.
- **PHP Extension**: `php81` (or relevant version in Alpine 3.23).
- **FPM Config**: Listens on port 9000. `daemonize = no`.

### MariaDB

- **Bind Address**: `0.0.0.0` (to allow connections from WordPress container).
- **Networking**: Exposed strictly on internal network port 3306.

---

## 🚑 Troubleshooting

| Issue | Possible Cause | Solution |
| :--- | :--- | :--- |
| **Connection Refused** | Container not running or port mismatch | Check `make ps`. Ensure NGINX maps 443:443. |
| **502 Bad Gateway** | NGINX cannot talk to WordPress | Check if WordPress is running (`make ps`). Check logs for PHP-FPM errors. |
| **Database Connection Error** | Credentials mismatch or MariaDB down | Verify `secrets/` files match `.env`. Check MariaDB logs. |
| **"Error establishing database connection"** | WP Config incorrect | Ensure `wp-config.php` (generated in entrypoint) uses correct DB_HOST (`mariadb`). |
| **Volume Permission Denied** | Host folder permissions | Run `chmod 777` on host data dirs (dev only) or fix ownership. |

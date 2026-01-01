*This project has been created as part of the 42 curriculum by mukibrok*

# Inception

## 📖 Description

This project aims to broaden your knowledge of system administration by using Docker to virtualize several Docker images, creating a personal web server. The goal is to set up a small infrastructure composed of different services following specific rules for security, performance, and best practices.

The infrastructure consists of:

- **NGINX** with TLS v1.2/v1.3 only.
- **WordPress** served via PHP-FPM.
- **MariaDB** as the database backend.
- A **Docker Network** to isolate communication between containers.
- **Docker Volumes** for data persistence.

All services are built from Alpine Linux (or Debian) base images and configured manually (no ready-made images like `nginx:latest` or `wordpress:latest`).

## 🛠 Instructions

### Prerequisites

- Docker and Docker Compose installed.
- `make` utility.
- `setup` of domain name mapping in `/etc/hosts`:

    ```bash
    127.0.0.1 mukibrok.42.fr
    ```

### Compilation & Installation

This project uses a `Makefile` to automate the build process.

To build the Docker images and set up the networks/volumes:

```bash
make
```

This command triggers `docker compose up --build`.

### Execution

- **Start**: `make` (or `make start` to run without rebuilding)
- **Stop**: `make stop` (stops containers)
- **Restart**: `make restart`
- **Status**: `make ps` (view running services)
- **Logs**: `make logs`

### Clean Up

To remove all containers, images, and **delete all data volumes**:

```bash
make clean
```

*Warning: This action is destructive and cannot be undone.*

## 📚 Resources & Documentation

Detailed documentation has been generated for this project:

- **[User Guide](USER_DOC.md)**: Instructions for end-users on how to access and use the services.
- **[Developer Guide](DEV_DOC.md)**: Technical details, architecture, and development workflows.

### AI Usage

This documentation and some debugging steps were assisted by an AI agent (Antigravity/Gemini). The AI was used to:

- Analyze configuration files (`Makefile`, `docker-compose.yml`).
- Generate comprehensive documentation files.
- Clarify architectural concepts.

## 🧠 Project Concepts

### Docker vs. Virtual Machines (VM)

- **Docker**: Uses containerization to share the host OS kernel. It is lightweight, starts in seconds, and packages the application with its dependencies.
- **VM**: Virtualizes the entire hardware, requiring a full OS installation for each instance. It is heavier, slower to start, but offers stronger isolation.
*In this project, Docker allows running multiple services (NGINX, WP, DB) on a single machine efficiently.*

### Secrets vs. Environment Variables

- **Environment Variables**: Stored in `.env` or passed via `environment:` in docker-compose. They are visible via `docker inspect` and logs, making them less secure for sensitive data.
- **Docker Secrets**: Stored in separate files (e.g., in `/run/secrets/` inside the container). They are encrypted at rest (in Swarm) or managed securely by Docker, preventing accidental exposure in logs.
*This project uses specific password files in `secrets/` to protect database credentials.*

### Docker Network vs. Host Network

- **Docker Network**: Creates an isolated virtual bridge. Containers can talk to each other by name (DNS resolution) without exposing ports to the host or outside world, unless explicitly mapped.
- **Host Network**: Containers share the host's IP stack. Port conflicts are common, and isolation is lost.
*We use a specific bridge network (`inception-network`) so MariaDB is only accessible to WordPress, not the outside world.*

### Volumes vs. Bind Mounts

- **Volumes**: Managed by Docker (in `/var/lib/docker/volumes`). Easier to back up and migrate.
- **Bind Mounts**: Maps a specific file or directory on the host to the container. Useful for development or specific configuration files.
*We use bind mounts (or driver opts pointing to specific folders) to persist MariaDB and WordPress data in `/home/mukibrok/data/` (or project equivalent).*

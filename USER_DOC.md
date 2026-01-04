# Inception Project - User Documentation

## 🚀 Quick Start

To start the project immediately, run the following command from the project root:

```bash
make
```

This will create the necessary data directories, build the Docker images, and start the services.

---

## 📋 Services Overview

This project consists of three main containerized services running on a dedicated network:

1. **NGINX**: The entry point for the website.
    - **Port**: 443 (TLS/SSL only)
    - **Function**: Serves as a secure reverse proxy and static file server.
    - **Security**: Uses self-signed certificates for TLS v1.2/v1.3.

2. **WordPress**: The content management system.
    - **Function**: Runs the website logic and connects to the database.
    - **listening**: Port 9000 (internal).

3. **MariaDB**: The database server.
    - **Function**: Stores WordPress data (posts, users, comments).
    - **Port**: 3306 (internal).

All services are configured to restart automatically unless explicitly stopped (`restart: unless-stopped`).

---

## 🛠 Project Management

Managing the project is simplified using the `Makefile`.

### Starting the Project

Build and start all services:

```bash
make
```

*Note 1: The first launch may ask for your password (`sudo`) to automatically configure the domain in `/etc/hosts`.*
*Note 2: It may check a few minutes as images are built and the database is initialized.*

### Stopping the Project

Stop all running containers:

```bash
make stop
```

### Restarting

Restart the containers:

```bash
make restart
```

### Viewing Status

Check the status of running containers:

```bash
make ps
```

Or view logs:

```bash
make logs
```

### Cleaning Up

**⚠️ WARNING**: This will stop containers and **permanently delete** all data volumes and database entries.

```bash
make clean
```

---

## 🌐 Accessing the Website

Once the project is running, you can access the WordPress site.

### URLs

- **Main Website**: [https://mukibrok.42.fr](https://mukibrok.42.fr)
- **Admin Dashboard**: [https://mukibrok.42.fr/wp-admin](https://mukibrok.42.fr/wp-admin)

> **Note**: Since this project uses self-signed certificates, your browser will show a "Not Secure" warning. You must accept the risk/proceed to view the site.

---

## 🔐 Credentials Management

Sensitive information such as passwords is managed securely using Docker Secrets.

### Storage Location

Credentials are stored in files within the `secrets/` directory on the host machine:

- `secrets/credentials.txt`: Contains the WordPress Admin password.
- `secrets/db_password.txt`: Database user password.
- `secrets/db_root_password.txt`: Database root password.

### Security Best Practices

- **Never commit secrets to Git** (these files should be in `.gitignore`).
- To change a password, update the corresponding file in `secrets/` and restart the containers.
- Inside the containers, secrets are mounted securely at `/run/secrets/`.

---

## 🩺 Health Checks & Troubleshooting

The services include built-in health checks to ensure they are running correctly.

### Verifying Status

Run `make ps` (or `docker compose -f srcs/docker-compose.yml ps`) to see the health status:

| Status | Meaning |
| :--- | :--- |
| `healthy` | The service is running and responding to checks. |
| `starting` | The service is initializing (wait a moment). |
| `unhealthy` | The service has failed its health check. |

### Common Issues

1. **"502 Bad Gateway"**:
    - NGINX is running, but WordPress is not responding yet.
    - **Fix**: Wait a minute for WordPress to finish starting up.

2. **Database Connection Error**:
    - WordPress cannot connect to MariaDB.
    - **Fix**: Check if MariaDB is `healthy`. If not, check logs: `docker compose -f srcs/docker-compose.yml logs mariadb`.

3. **Volume Permissions**:
    - If services fail to start, ensure the data directories exist and have correct permissions.
    - **Data Paths**:
        - `/Users/muxammad/Desktop/Inception/data/wordpress`
        - `/Users/muxammad/Desktop/Inception/data/mariadb`

### Troubleshooting Commands

- **View Logs**: `make logs`
- **Rebuild specific service**: `docker compose -f srcs/docker-compose.yml up -d --build <service_name>`

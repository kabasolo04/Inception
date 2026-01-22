# 🛠️ Developer Documentation - Inception Project

**Repository:** [https://github.com/kabasolo04/Inception](https://github.com/kabasolo04/Inception)

## 📑 Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Services Breakdown](#services-breakdown)
3. [Docker Configuration](#docker-configuration)
4. [Network & Volumes](#network--volumes)
5. [Security Implementation](#security-implementation)
6. [Build Process](#build-process)
7. [Development Workflow](#development-workflow)
8. [Debugging Guide](#debugging-guide)
9. [Code Structure](#code-structure)

---

## Architecture Overview

The Inception project implements a **three-tier microservices architecture** using Docker containers:

```
┌─────────────────────────────────────────────────┐
│                 Host Machine                     │
│  ┌───────────────────────────────────────────┐  │
│  │        Docker Network (bridge)            │  │
│  │  ┌──────────┐   ┌──────────┐  ┌────────┐ │  │
│  │  │  NGINX   │──▶│WordPress │─▶│MariaDB │ │  │
│  │  │  :443    │   │  :9000   │  │ :3306  │ │  │
│  │  └──────────┘   └──────────┘  └────────┘ │  │
│  └───────────────────────────────────────────┘  │
│         │              │              │          │
│      /data/web     /data/web    /data/database  │
└─────────────────────────────────────────────────┘
```

### Service Communication Flow

1. **Client** → NGINX (443/HTTPS)
2. **NGINX** → WordPress (9000/FastCGI)
3. **WordPress** → MariaDB (3306/MySQL)

---

## Services Breakdown

### 1. NGINX Service

**Container:** `nginx`  
**Base Image:** `alpine:3.22`  
**Exposed Ports:** `443` (HTTPS only)

#### Key Components

- **Dockerfile:** [srcs/requirements/nginx/Dockerfile](srcs/requirements/nginx/Dockerfile)
- **Configuration:** [srcs/requirements/nginx/conf/nginx.conf](srcs/requirements/nginx/conf/nginx.conf)
- **Entrypoint:** [srcs/requirements/nginx/tools/entrypoint.sh](srcs/requirements/nginx/tools/entrypoint.sh)

#### Functionality

- Acts as **reverse proxy** with TLS/SSL encryption
- Serves static files from `/var/www/html`
- Forwards PHP requests to WordPress via FastCGI
- SSL certificates generated via OpenSSL in entrypoint script

#### Configuration Details

```nginx
listen 443 ssl;
ssl_certificate /etc/nginx/ssl/inception.crt;
ssl_certificate_key /etc/nginx/ssl/inception.key;
fastcgi_pass wp-php:9000;
```

---

### 2. WordPress Service

**Container:** `wp-php`  
**Base Image:** `alpine:3.22`  
**Exposed Ports:** `9000` (PHP-FPM)

#### Key Components

- **Dockerfile:** [srcs/requirements/wordpress/Dockerfile](srcs/requirements/wordpress/Dockerfile)
- **Configuration:** [srcs/requirements/wordpress/conf/wp.conf](srcs/requirements/wordpress/conf/wp.conf)
- **Initialization Script:** [srcs/requirements/wordpress/tools/script.sh](srcs/requirements/wordpress/tools/script.sh)
- **PHP Config:** [srcs/requirements/wordpress/tools/php.ini](srcs/requirements/wordpress/tools/php.ini)

#### Functionality

- Runs **WordPress** with **PHP 8.3 + PHP-FPM**
- Uses **WP-CLI** for automated setup
- Creates admin and regular user accounts
- Connects to MariaDB using credentials from secrets

#### Setup Process

```bash
1. Download WordPress core via WP-CLI
2. Create wp-config.php with database credentials
3. Run core install with admin user
4. Create additional regular user
5. Start PHP-FPM in foreground mode
```

#### Dependencies

```dockerfile
php php-phar php-fpm php-mysqli php-mbstring curl
```

---

### 3. MariaDB Service

**Container:** `mariadb`  
**Base Image:** `alpine:3.22`  
**Exposed Ports:** `3306` (MySQL)

#### Key Components

- **Dockerfile:** [srcs/requirements/mariadb/Dockerfile](srcs/requirements/mariadb/Dockerfile)
- **Configuration:** [srcs/requirements/mariadb/conf/db.conf](srcs/requirements/mariadb/conf/db.conf)
- **Initialization Script:** [srcs/requirements/mariadb/tools/script.sh](srcs/requirements/mariadb/tools/script.sh)

#### Functionality

- Provides MySQL-compatible database
- Initializes database on first run
- Creates WordPress database and user
- Secured with root and user passwords from secrets

#### Initialization SQL

```sql
ALTER USER 'root'@'localhost' IDENTIFIED BY '$DB_ROOT_PASSWORD';
CREATE DATABASE IF NOT EXISTS `wordpress`;
CREATE OR REPLACE USER 'wpuser'@'%' IDENTIFIED BY '$DB_PASSWORD';
GRANT ALL PRIVILEGES ON `wordpress`.* TO 'wpuser'@'%';
FLUSH PRIVILEGES;
```

---

## Docker Configuration

### Docker Compose Structure

**File:** [srcs/docker-compose.yml](srcs/docker-compose.yml)

#### Key Features

- **Networks:** Custom bridge network `inception_network`
- **Volumes:** Host bind mounts for data persistence
- **Secrets:** File-based secrets for sensitive data
- **Dependencies:** Ordered startup (MariaDB → WordPress → NGINX)

### Environment Variables

**File:** [srcs/.env](srcs/.env)

| Variable      | Default Value      | Purpose                    |
|---------------|--------------------|----------------------------|
| `DB_NAME`     | wordpress          | Database name              |
| `DB_USER`     | wpuser             | Database user              |
| `DB_HOST`     | mariadb            | Database hostname          |
| `DOMAIN_NAME` | kabasolo.42.fr     | Website domain             |
| `WP_TITLE`    | mySite             | WordPress site title       |
| `WP_PORT`     | 443                | HTTPS port                 |

### Secrets Management

**Directory:** `secrets/`

- `db_password.txt` - MariaDB user password (random 16-byte base64)
- `db_root_password.txt` - MariaDB root password (random 16-byte base64)
- `credentials.txt` - WordPress user credentials

---

## Network & Volumes

### Network Configuration

```yaml
networks:
  inception_network:
    driver: bridge
```

- **Type:** Bridge network (isolated from host)
- **Purpose:** Internal service-to-service communication
- **DNS:** Automatic service name resolution

### Volume Mounting

```yaml
volumes:
  - /home/${USER}/data/web:/var/www/html
  - /home/${USER}/data/database:/var/lib/mysql
```

- **WordPress Data:** `/home/${USER}/data/web`
- **Database Data:** `/home/${USER}/data/database`
- **Persistence:** Survives container restarts

---

## Security Implementation

### 1. TLS/SSL Encryption

- Self-signed certificates generated in NGINX entrypoint
- HTTPS-only (no HTTP port 80)
- Modern TLS configuration

### 2. Docker Secrets

- Passwords stored in separate files
- Mounted at `/run/secrets/` in containers
- Not visible in image layers or `docker inspect`

### 3. Network Isolation

- Services only expose ports internally to Docker network
- Only NGINX port 443 exposed to host
- No direct database access from outside

### 4. User Permissions

- MariaDB runs as `mysql` user
- Proper file ownership and permissions

---

## Build Process

### Makefile Targets

**File:** [Makefile](Makefile)

#### Setup Commands

```makefile
make setup    # Complete setup (host + env + secrets)
make host     # Add domain to /etc/hosts
make env      # Generate .env file
make secrets  # Generate secrets with random passwords
```

#### Container Management

```makefile
make up       # Build and start all services
make down     # Stop and remove containers + volumes
make start    # Start existing containers
make stop     # Stop running containers
make clean    # Stop containers and clean volumes
make fclean   # Full cleanup (images + data)
make re       # Rebuild from scratch
```

### Build Order

1. MariaDB (no dependencies)
2. WordPress (depends on MariaDB)
3. NGINX (depends on WordPress)

---

## Development Workflow

### Initial Setup

```bash
# 1. Clone the repository
git clone <repo-url> && cd Inception

# 2. Run automatic setup
make setup

# 3. Build and start containers
make up

# 4. Access WordPress
open https://kabasolo.42.fr
```

### Making Changes

```bash
# Edit configuration files
vim srcs/requirements/nginx/conf/nginx.conf

# Rebuild specific service
docker compose -f srcs/docker-compose.yml build nginx

# Restart service
docker compose -f srcs/docker-compose.yml restart nginx

# Or rebuild everything
make re
```

### Viewing Logs

```bash
# All services
docker compose -f srcs/docker-compose.yml logs -f

# Specific service
docker compose -f srcs/docker-compose.yml logs -f nginx
```

---

## Debugging Guide

### Common Commands

#### Access Container Shell

```bash
# MariaDB
docker exec -it mariadb sh

# WordPress
docker exec -it wp-php sh

# NGINX
docker exec -it nginx sh
```

#### Check Database

```bash
docker exec -it mariadb sh
mysql -u root -p  # Use password from secrets/db_root_password.txt

SHOW DATABASES;
USE wordpress;
SHOW TABLES;
SELECT * FROM wp_users;
```

#### Check WordPress Files

```bash
docker exec -it wp-php sh
ls -la /var/www/html/
cat /var/www/html/wp-config.php
```

#### Test NGINX Configuration

```bash
docker exec -it nginx sh
nginx -t  # Test configuration syntax
cat /etc/nginx/nginx.conf
ls -l /etc/nginx/ssl/
```

#### Inspect Network

```bash
docker network inspect inception_inception_network
```

#### Check Secrets

```bash
docker exec -it mariadb cat /run/secrets/db_password
docker exec -it wordpress cat /run/secrets/db_password
```

### Troubleshooting

| Problem | Solution |
|---------|----------|
| Cannot access website | Check `/etc/hosts` has `127.0.0.1 kabasolo.42.fr` |
| SSL certificate error | Delete and regenerate: `make fclean && make up` |
| Database connection error | Verify secrets match in MariaDB and WordPress |
| Port already in use | Stop conflicting service: `sudo lsof -i :443` |
| Permission denied on volumes | Check ownership: `ls -l ~/data/` |

---

## Code Structure

```
Inception/
├── Makefile                        # Build automation
├── README.md                       # User-facing documentation
├── DEV_DOC.md                      # This file (developer docs)
├── USER_DOC.md                     # User guide
├── secrets/                        # Sensitive credentials (not in git)
│   ├── credentials.txt             # WP user credentials
│   ├── db_password.txt             # DB user password
│   └── db_root_password.txt        # DB root password
└── srcs/
    ├── .env                        # Environment variables
    ├── docker-compose.yml          # Container orchestration
    └── requirements/
        ├── nginx/
        │   ├── Dockerfile          # NGINX image definition
        │   ├── conf/
        │   │   └── nginx.conf      # Web server config
        │   └── tools/
        │       └── entrypoint.sh   # SSL generation + startup
        ├── wordpress/
        │   ├── Dockerfile          # WordPress image definition
        │   ├── conf/
        │   │   └── wp.conf         # PHP-FPM pool config
        │   └── tools/
        │       ├── script.sh       # WP installation script
        │       └── php.ini         # PHP configuration
        └── mariadb/
            ├── Dockerfile          # MariaDB image definition
            ├── conf/
            │   └── db.conf         # MySQL server config
            └── tools/
                └── script.sh       # DB initialization script
```

---

## Additional Notes

### 42 Project Requirements

✅ Each service runs in dedicated container  
✅ Custom Dockerfiles (no ready-made images)  
✅ Alpine Linux as base  
✅ TLS 1.2/1.3 for NGINX  
✅ Docker network for service communication  
✅ Volumes for data persistence  
✅ Containers restart on crash  
✅ No passwords in Dockerfiles  
✅ Strong passwords via secrets  

### Best Practices

- Always use secrets for sensitive data
- Keep images minimal (Alpine base)
- One process per container
- Use health checks for reliability
- Version pin all dependencies
- Document all configuration changes
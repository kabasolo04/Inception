# 🛠️ Developer Documentation - Inception Project

**Repository:** [https://github.com/kabasolo04/Inception](https://github.com/kabasolo04/Inception)

## 📑 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Initial Setup](#initial-setup)
3. [Makefile Usage](#makefile-usage)
4. [Docker Compose Commands](#docker-compose-commands)
5. [Data Persistence](#data-persistence)
6. [Architecture Overview](#architecture-overview)
7. [Services Breakdown](#services-breakdown)
8. [Network & Security](#network--security)
9. [Development Workflow](#development-workflow)
10. [Debugging Guide](#debugging-guide)

---

## Prerequisites

### System Requirements

- **OS:** Linux (Ubuntu 20.04+ / Debian 11+ recommended)
- **Architecture:** x86_64 or ARM64
- **Disk Space:** Minimum 2GB free space
- **RAM:** Minimum 2GB available

### Required Software

| Software | Minimum Version | Check Command |
|----------|----------------|---------------|
| Docker | 20.10+ | `docker --version` |
| Docker Compose | 2.0+ | `docker compose version` |
| Make | 4.0+ | `make --version` |
| OpenSSL | 1.1.1+ | `openssl version` |
| Git | 2.25+ | `git --version` |

### Installation

**Ubuntu/Debian:**
```bash
# Update package index
sudo apt update

# Install Docker
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER
newgrp docker

# Install Make and OpenSSL
sudo apt install -y make openssl

# Verify installations
docker --version
docker compose version
make --version
```

### Permissions

- **Docker:** User must be in `docker` group
- **Hosts file:** Sudo access required for `/etc/hosts` modification
- **Data directories:** Write access to `/home/$USER/data/`

---

## Initial Setup

### 1. Clone Repository

```bash
git clone https://github.com/kabasolo04/Inception.git
cd Inception
```

### 2. Project Structure Overview

```
Inception/
├── Makefile                   # Build automation
├── README.md                  # Project overview
├── USER_DOC.md               # End-user documentation
├── DEV_DOC.md                # This file
├── secrets/                   # Credentials (generated)
│   ├── credentials.txt        # WordPress users
│   ├── db_password.txt        # DB user password
│   └── db_root_password.txt   # DB root password
└── srcs/
    ├── .env                   # Environment variables
    ├── docker-compose.yml     # Container orchestration
    └── requirements/          # Service definitions
        ├── nginx/
        ├── wordpress/
        └── mariadb/
```

### 3. Automated Setup

```bash
make setup
```

This executes three targets:
1. `make host` - Adds domain to `/etc/hosts`
2. `make env` - Creates `srcs/.env` with default values
3. `make secrets` - Generates random passwords

### 4. Manual Setup (Optional)

If you prefer manual control:

```bash
# Add domain to hosts
echo "127.0.0.1 kabasolo.42.fr" | sudo tee -a /etc/hosts

# Create environment file
cat > srcs/.env << EOF
DB_NAME=wordpress
DB_USER=wpuser
DB_HOST=mariadb
DOMAIN_NAME=kabasolo.42.fr
WP_TITLE=mySite
EOF

# Create secrets directory
mkdir -p secrets

# Generate passwords
openssl rand -base64 16 > secrets/db_root_password.txt
openssl rand -base64 16 > secrets/db_password.txt

# Create WordPress credentials
cat > secrets/credentials.txt << EOF
WP_USER_NAME=your_username
WP_USER_EMAIL=your@email.com
WP_USER_PASSWORD=$(openssl rand -base64 12)
WP_ADMIN_USER=admin_user
WP_ADMIN_EMAIL=admin@email.com
WP_ADMIN_PASSWORD=$(openssl rand -base64 12)
EOF
```

### 5. Build and Start

```bash
make up
```

First build takes 2-5 minutes to:
- Download Alpine base images
- Install packages
- Build custom images
- Create containers
- Initialize database
- Install WordPress

---

## Makefile Usage

### Setup Targets

| Target | Description | Usage |
|--------|-------------|-------|
| `make setup` | Complete automated setup | Initial configuration |
| `make host` | Add domain to `/etc/hosts` | Domain configuration |
| `make env` | Generate `srcs/.env` file | Environment setup |
| `make secrets` | Create secrets with random passwords | Credential generation |

### Container Management

| Target | Description | Use Case |
|--------|-------------|----------|
| `make up` | Build and start containers | First run or after `down` |
| `make start` | Start existing containers | Resume after `stop` |
| `make stop` | Stop running containers | Temporary pause |
| `make down` | Stop and remove containers | Clean shutdown |
| `make restart` | Stop then start containers | Apply configuration changes |

### Cleanup Targets

| Target | Description | What Gets Removed |
|--------|-------------|-------------------|
| `make clean` | Basic cleanup | Containers + Docker volumes |
| `make fclean` | Full cleanup | + Images + host data directories |
| `make nuke` | Nuclear option | Containers + volumes + orphans |

### Rebuild Targets

| Target | Description | Use Case |
|--------|-------------|----------|
| `make re` | fclean + up | Complete rebuild |
| `make rebuild` | fclean + all | Full reset with fresh setup |

### Implementation Details

**Key Makefile Variables:**
```makefile
SRCSDIR := srcs
COMPOSE := docker compose -f $(SRCSDIR)/docker-compose.yml
ENV := --env-file $(SRCSDIR)/.env
HOST := kabasolo.42.fr
```

**Example Target:**
```makefile
up:
	@echo "🟢 Starting containers..."
	@$(COMPOSE) $(ENV) up -d --build
```

---

## Docker Compose Commands

### Direct Docker Compose Usage

When you need more control than Makefile provides:

```bash
# Base command
docker compose -f srcs/docker-compose.yml --env-file srcs/.env <command>
```

### Common Commands

**Build and Start:**
```bash
# Build all services
docker compose -f srcs/docker-compose.yml build

# Build specific service
docker compose -f srcs/docker-compose.yml build nginx

# Start services
docker compose -f srcs/docker-compose.yml up -d

# Start with rebuild
docker compose -f srcs/docker-compose.yml up -d --build
```

**Container Management:**
```bash
# List running containers
docker compose -f srcs/docker-compose.yml ps

# Stop services
docker compose -f srcs/docker-compose.yml stop

# Start stopped services
docker compose -f srcs/docker-compose.yml start

# Restart specific service
docker compose -f srcs/docker-compose.yml restart nginx
```

**Logs and Debugging:**
```bash
# View all logs
docker compose -f srcs/docker-compose.yml logs

# Follow logs in real-time
docker compose -f srcs/docker-compose.yml logs -f

# Logs for specific service
docker compose -f srcs/docker-compose.yml logs mariadb

# Last 50 lines
docker compose -f srcs/docker-compose.yml logs --tail=50
```

**Cleanup:**
```bash
# Stop and remove containers
docker compose -f srcs/docker-compose.yml down

# Remove containers and volumes
docker compose -f srcs/docker-compose.yml down -v

# Remove containers, volumes, and orphans
docker compose -f srcs/docker-compose.yml down -v --remove-orphans
```

**Executing Commands:**
```bash
# Execute command in running container
docker compose -f srcs/docker-compose.yml exec nginx sh

# Run one-off command
docker compose -f srcs/docker-compose.yml run --rm wordpress ls -la /var/www/html
```

### Service-Specific Operations

**Rebuild single service:**
```bash
docker compose -f srcs/docker-compose.yml stop nginx
docker compose -f srcs/docker-compose.yml rm -f nginx
docker compose -f srcs/docker-compose.yml build nginx
docker compose -f srcs/docker-compose.yml up -d nginx
```

**Scale services (if applicable):**
```bash
docker compose -f srcs/docker-compose.yml up -d --scale wordpress=2
```

---

## Data Persistence

### Volume Strategy

This project uses **Docker named volumes** for data persistence. Named volumes are managed by Docker and are more portable than bind mounts.

### Data Locations

| Service | Container Path | Docker Volume | Purpose |
|---------|---------------|---------------|---------|
| WordPress | `/var/www/html` | `inception_wordpress_data` | WordPress files, themes, plugins |
| MariaDB | `/var/lib/mysql` | `inception_mariadb_data` | Database files |

### docker-compose.yml Configuration

```yaml
volumes:
  wordpress_data:
  mariadb_data:

services:
  wordpress:
    volumes:
      - wordpress_data:/var/www/html
  
  mariadb:
    volumes:
      - mariadb_data:/var/lib/mysql
```

### Viewing Docker Volumes

```bash
# List all volumes
docker volume ls

# Inspect specific volume
docker volume inspect inception_wordpress_data
docker volume inspect inception_mariadb_data

# View volume location on host
docker volume inspect inception_wordpress_data --format='{{.Mountpoint}}'
```

### Data Lifecycle

**On first `make up`:**
```bash
# Docker creates named volumes automatically
docker volume create inception_wordpress_data
docker volume create inception_mariadb_data

# WordPress installation populates the volume
# MariaDB initialization populates the volume
```

**Data persists through:**
- `make stop` / `make start`
- `make down` / `make up`
- Container crashes/restarts

**Data is removed by:**
- `make fclean` (includes volume cleanup)
- Manual deletion: `docker volume rm inception_wordpress_data inception_mariadb_data`

### Accessing Volume Data on Host

By default, Docker volumes are stored in:
```bash
/var/lib/docker/volumes/
```

**Find the actual location:**
```bash
# Get full path to WordPress volume
docker volume inspect inception_wordpress_data --format='{{.Mountpoint}}'

# Get full path to Database volume
docker volume inspect inception_mariadb_data --format='{{.Mountpoint}}'
```

### Backup Strategy

**Manual Backup:**
```bash
# Stop containers to ensure consistency
make stop

# Backup WordPress volume
docker run --rm -v inception_wordpress_data:/data -v $(pwd):/backup alpine tar czf /backup/wordpress-backup.tar.gz -C /data .

# Backup database volume
docker run --rm -v inception_mariadb_data:/data -v $(pwd):/backup alpine tar czf /backup/database-backup.tar.gz -C /data .

# Restart containers
make start
```

**Automated Backup Script:**
```bash
#!/bin/bash
BACKUP_DIR="/backups/inception"
mkdir -p $BACKUP_DIR

docker compose -f srcs/docker-compose.yml stop

docker run --rm -v inception_wordpress_data:/data -v $BACKUP_DIR:/backup alpine tar czf /backup/web-$(date +%Y%m%d-%H%M).tar.gz -C /data .
docker run --rm -v inception_mariadb_data:/data -v $BACKUP_DIR:/backup alpine tar czf /backup/db-$(date +%Y%m%d-%H%M).tar.gz -C /data .

docker compose -f srcs/docker-compose.yml start
```

### Restore from Backup

```bash
# Stop containers
make down

# Create fresh volumes
docker volume create inception_wordpress_data
docker volume create inception_mariadb_data

# Restore WordPress files
docker run --rm -v inception_wordpress_data:/data -v $(pwd):/backup alpine tar xzf /backup/wordpress-backup.tar.gz -C /data

# Restore database
docker run --rm -v inception_mariadb_data:/data -v $(pwd):/backup alpine tar xzf /backup/database-backup.tar.gz -C /data

# Start containers
make up
```

### Database Export/Import

**Export database:**
```bash
docker exec mariadb mysqldump -u root -p$(cat secrets/db_root_password.txt) wordpress > backup.sql
```

**Import database:**
```bash
cat backup.sql | docker exec -i mariadb mysql -u root -p$(cat secrets/db_root_password.txt) wordpress
```
---

## Architecture Overviewker exec mariadb mysqldump -u root -p$(cat secrets/db_root_password.txt) wordpress > backup.sql
```

**Import database:**
```bash
cat backup.sql | docker exec -i mariadb mysql -u root -p$(cat secrets/db_root_password.txt) wordpress
```

### File Permissions

**Checking ownership:**
```bash
ls -ld ~/data/web/
ls -ld ~/data/database/
```

**Fixing permissions:**
```bash
# WordPress files should be writable by www-data (container user)
sudo chown -R $(id -u):$(id -g) ~/data/web/

# Database files owned by mysql user (mapped to host UID)
sudo chown -R $(id -u):$(id -g) ~/data/database/
```

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

Docker Compose respects `depends_on` directives:

1. **MariaDB** (no dependencies)
2. **WordPress** (depends on MariaDB)
3. **NGINX** (depends on WordPress)

---

## Network & Security

### Network Configuration

```yaml
networks:
  inception_network:
    driver: bridge
```

**Features:**
- Isolated bridge network
- Automatic DNS resolution (containers reach each other by service name)
- No direct host network access

**Testing connectivity:**
```bash
# From WordPress to MariaDB
docker exec wp-php ping mariadb

# From NGINX to WordPress
docker exec nginx ping wp-php
```

### Security Implementation

**1. TLS/SSL Encryption:**
- Self-signed certificates generated on first run
- Certificate location: `/etc/nginx/ssl/` in nginx container
- HTTPS only (port 443, no HTTP)

**2. Docker Secrets:**
```yaml
secrets:
  db_password:
    file: ../secrets/db_password.txt
  db_root_password:
    file: ../secrets/db_root_password.txt
```

Secrets mounted at `/run/secrets/` inside containers (read-only).

**3. Port Exposure:**
- **NGINX:** 443 exposed to host
- **WordPress:** 9000 internal only
- **MariaDB:** 3306 internal only

**4. Environment Variables:**
Non-sensitive configuration in `srcs/.env`:
```bash
DB_NAME=wordpress      # Public
DB_USER=wpuser         # Public
DB_HOST=mariadb        # Public
DOMAIN_NAME=kabasolo.42.fr
WP_TITLE=mySite
```

Sensitive data in `secrets/` (gitignored):
```bash
DB_PASSWORD           # In db_password.txt
DB_ROOT_PASSWORD      # In db_root_password.txt
WP_*_PASSWORD         # In credentials.txt
```

---

## Development Workflow

### Typical Development Cycle

**1. Make Configuration Changes:**
```bash
# Edit NGINX config
vim srcs/requirements/nginx/conf/nginx.conf

# Edit WordPress PHP settings
vim srcs/requirements/wordpress/tools/php.ini

# Edit MariaDB config
vim srcs/requirements/mariadb/conf/db.conf
```

**2. Rebuild Affected Service:**
```bash
# Rebuild and restart specific service
docker compose -f srcs/docker-compose.yml build nginx
docker compose -f srcs/docker-compose.yml up -d nginx

# Or use make
make re
```

**3. Test Changes:**
```bash
# Check logs for errors
docker compose -f srcs/docker-compose.yml logs nginx

# Test endpoint
curl -k https://kabasolo.42.fr
```

**4. Debug if Needed:**
```bash
# Enter container
docker exec -it nginx sh

# Check configuration
nginx -t

# View running processes
ps aux
```

### Working with WordPress Files

WordPress files are directly accessible on the host:

```bash
# Edit theme files
vim ~/data/web/wp-content/themes/your-theme/style.css

# Install plugin manually
cd ~/data/web/wp-content/plugins/
wget https://downloads.wordpress.org/plugin/your-plugin.zip
unzip your-plugin.zip
```

Changes reflect immediately (no container rebuild needed).

### Database Development

**Access MySQL shell:**
```bash
docker exec -it mariadb mysql -u root -p$(cat secrets/db_root_password.txt)
```

**Common queries:**
```sql
-- Show databases
SHOW DATABASES;

-- Use WordPress database
USE wordpress;

-- Show tables
SHOW TABLES;

-- View users
SELECT * FROM wp_users;

-- Update admin email
UPDATE wp_users SET user_email='new@email.com' WHERE user_login='admin';
```

### Hot Reload vs Rebuild Required

| Change Type | Hot Reload | Rebuild Required |
|-------------|------------|------------------|
| WordPress PHP files | ✅ | ❌ |
| WordPress themes/plugins | ✅ | ❌ |
| NGINX config files | ❌ | ✅ restart nginx |
| PHP-FPM config | ❌ | ✅ restart wordpress |
| MariaDB config | ❌ | ✅ restart mariadb |
| Dockerfile changes | ❌ | ✅ rebuild image |
| docker-compose.yml | ❌ | ✅ down + up |

### Version Control

**.gitignore should include:**
```gitignore
secrets/
srcs/.env
.DS_Store
```

**Commit workflow:**
```bash
# Check status
git status

# Add changes (excluding secrets)
git add srcs/requirements/
git add Makefile README.md

# Commit
git commit -m "Updated nginx configuration"

# Push
git push origin main
```

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
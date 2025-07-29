# 🐳 Inception - 42 Project

This project consists of setting up a **Docker-based infrastructure** composed of multiple containers, each running different services, and configured to work together as a full WordPress web server.

## 📦 Project Overview

You'll build a multi-service system using **Docker Compose**, managing:

- **Nginx** with SSL
- **WordPress + PHP-FPM**  
- **MariaDB**  

Everything is containerized, reproducible, and isolated — all from scratch.

## 🏁 How to start

Just type `make` / `make all`, and you will have a little display of how to set up and use some commands in order to easily manage the containers.

## 🔑 Set up variables

### `secrets/*.txt`
| Key                 | Description                            |
|---------------------|----------------------------------------|
| `DB_PASSWORD`       | MariaDB user password                  |
| `WP_ADMIN_PASSWORD` | WordPress regular user password        |

### `srcs/.env`
| Key                 | Description                            |
|---------------------|----------------------------------------|
| `DB_NAME`           | MariaDB database name                  |
| `DB_USER`           | MariaDB user name                      |
| `DOMAIN_NAME`       | Website domain name                    |
| `WP_TITLE`          | WordPress site title                   |
| `WP_ADMIN_USER`     | WordPress admin user name              |
| `WP_ADMIN_EMAIL`    | WordPress admin user email             |
| `WP_USER_NAME`      | WordPress regular user name            |
| `WP_USER_EMAIL`     | WordPress regular user email           |
| `WP_USER_ROLE`      | WordPress regular user role            |
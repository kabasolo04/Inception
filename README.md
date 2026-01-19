# 🐳 Inception - 42 Project

*This project has been created as part of the 42 curriculum by kabasolo.*

## Description

This project consists of setting up a **Docker-based infrastructure** composed of multiple containers, each running different services, and configured to work together as a full WordPress web server.

You'll build a multi-service system using **Docker Compose**, managing:

- **Nginx** with SSL
- **WordPress + PHP-FPM**  
- **MariaDB**  

Everything is containerized, reproducible, and isolated — all from scratch.

## 🏁 How to start

### `Automatic setup:`
| Command             | Description                            |
|---------------------|----------------------------------------|
| make setup          | You just gotta change the "replace" in the secrets

### `Individual setup steps:`
| Command             | Description                            |
|---------------------|----------------------------------------|
| make host           | Introduces 'kabasolo.42.fr' as a valid host to your machine
| make ssl            | Generate SSL certificate for NGINX
| make env            | Create a new srcs/.env
| make secrets        | Create secrets/ folder with placeholders to replace

### `Available Makefile commands:`
| Command             | Description                            |
|---------------------|----------------------------------------|
| make up             |  Build and start containers
| make down           |  Stop and remove containers and volumes
| make start          |  Start existing (stopped) containers
| make stop           |  Stop running containers
| make clean          |  Stop and remove containers + volumes
| make fclean         |  Like clean + remove images and persistent files
| make nuke           |  Like down but also removes orphans
| make re             |  fclean + up
| make rebuild        |  fclean + all (e.g. build SSL then up)

You can also just type `make` / `make all` to see all these options in the root of the project page.

## 🔑 Set up variables

### `secrets/credentials.txt`
| Key                 | Description                            |
|---------------------|----------------------------------------|
| `WP_USER_NAME`      | WordPress regular user name            |
| `WP_USER_EMAIL`     | WordPress regular user email           |
| `WP_USER_PASSWORD`  | Wordpress regular user password        |
| `WP_ADMIN_USER`     | WordPress admin user name              |
| `WP_ADMIN_EMAIL`    | WordPress admin user email             |
| `WP_ADMIN_PASSWORD` | WordPress admin user password          |

### `secrets/*.txt`
| Key                 | Description                            |
|---------------------|----------------------------------------|
| `DB_PASSWORD`       | MariaDB user password                  |
| `DB_ROOT_PASSWORD`  | MariaDB root password                  |

### `srcs/.env` (already set by default)
| Key                 | Description                            |
|---------------------|----------------------------------------|
| `DB_NAME`           | MariaDB database name                  |
| `DB_USER`           | MariaDB user name                      |
| `DB_HOST`           | MariaDB host name                      |
| `DOMAIN_NAME`       | Website domain name                    |
| `WP_TITLE`          | WordPress site title                   |
NAME=inception
COMPOSE=docker compose -f srcs/docker-compose.yml
ENV=--env-file srcs/.env
VOLUME=wordpress_data
SSl_DIR=srcs/requirements/nginx/tools/

.PHONY: all up down start stop clean fclean rebuild ssl

all:

SHELL := /bin/bash

setup:
	@mkdir -p secrets

	@>srcs/.env
	@>secrets/credentials.txt
	
	@echo "📄 Generating .env and credentials.txt..."
	@{ \
		read -p "Enter DB Username: " dbuser; \
		read -p "Enter MariaDB Username: " mariadb_user; \
		echo "WORDPRESS_DB_USER=$$dbuser" >> srcs/.env; \
		echo "MYSQL_USER=$$mariadb_user" >> srcs/.env; \
		echo "WORDPRESS_DB_USER=$$dbuser" >> secrets/credentials.txt; \
		echo "MYSQL_USER=$$mariadb_user" >> secrets/credentials.txt; \
	}

	@echo "🔐 Enter DB Password:"
	@read dbpass; echo $$dbpass > secrets/db_password.txt

	@echo "🔐 Enter DB Root Password:"
	@read dbroot; echo $$dbroot > secrets/db_root_password.txt

	@echo "✅ Secrets and env set up!"

ssl:
	@mkdir -p srcs/requirements/nginx/tools

	@>$(SSl_DIR)nginx.key
	@>$(SSl_DIR)nginx.crt

	@echo "🔐 Creating SSL certificate..."
	@openssl req -x509 -nodes -days 365 -subj "/C=CA/ST=QC/O=C Inc/CN=e.com" -newkey rsa:2048 -keyout $(SSl_DIR)nginx.key -out $(SSl_DIR)nginx.crt
	
	@echo "✅ SSL certificate created."

up:
	@echo "🟢 Starting containers..."
	@$(COMPOSE) $(ENV) up -d --build

down:
	@echo "🔴 Stopping and removing containers..."
	@$(COMPOSE) $(ENV) down

start:
	@echo "🟢 Starting containers..."
	@$(COMPOSE) $(ENV) start

stop:
	@echo "⛔ Stopping containers..."
	@$(COMPOSE) $(ENV) stop

nuke:		
	@$(COMPOSE) $(ENV) down -v --remove-orphans

clean:
	@echo "🧹 Removing containers and volumes..."
	@$(COMPOSE) $(ENV) down -v

fclean: clean
	@echo "🔥 Removing docker images and volumes..."
	@docker volume rm $(VOLUME) 2>/dev/null || true
	@docker image prune -af
	@docker container prune -f

rebuild: fclean all

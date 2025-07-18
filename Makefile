NAME=inception
COMPOSE=docker compose -f srcs/docker-compose.yml
ENV=--env-file srcs/.env
VOLUME=wordpress_data
SSl_DIR=srcs/requirements/nginx/tools/

.PHONY: all up down start stop clean fclean rebuild ssl

all:

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
	@$(COMPOSE) $(ENV) down -v

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
	@sudo rm -rf /home/$(USER)/data

re: fclean up

rebuild: fclean all

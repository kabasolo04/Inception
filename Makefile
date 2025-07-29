NAME        := inception
SRCSDIR     := srcs
COMPOSE     := docker compose -f $(SRCSDIR)/docker-compose.yml
ENV         := --env-file $(SRCSDIR)/.env
VOLUME      := wordpress_data
SSL_DIR     := $(SRCSDIR)/requirements/nginx/tools

GREEN   := \033[1;32m
RED     := \033[1;31m
BLUE    := \033[1;34m
NC      := \033[0m

.PHONY: all up down start stop clean fclean rebuild re ssl nuke create-env secrets

all: help

ssl:
	@mkdir -p $(SSL_DIR)
	@>$(SSL_DIR)/nginx.key
	@>$(SSL_DIR)/nginx.crt
	@echo "$(BLUE)🔐 Creating SSL certificate...$(NC)"
	@openssl req -x509 -nodes -days 365 -subj "/C=CA/ST=QC/O=C Inc/CN=e.com" -newkey rsa:2048 \
		-keyout $(SSL_DIR)/nginx.key -out $(SSL_DIR)/nginx.crt
	@echo "$(GREEN)✅ SSL certificate created.$(NC)"

up:
	@echo "$(GREEN)🟢 Starting containers...$(NC)"
	@$(COMPOSE) $(ENV) up -d --build

down:
	@echo "$(RED)🔴 Stopping and removing containers...$(NC)"
	@$(COMPOSE) $(ENV) down -v

start:
	@echo "$(GREEN)▶️ Starting containers...$(NC)"
	@$(COMPOSE) $(ENV) start

stop:
	@echo "$(RED)⏹️ Stopping containers...$(NC)"
	@$(COMPOSE) $(ENV) stop

nuke:
	@echo "$(RED)💣 Nuking containers and orphans...$(NC)"
	@$(COMPOSE) $(ENV) down -v --remove-orphans

clean: down
	@echo "$(RED)🧹 Containers and Docker volumes removed.$(NC)"

fclean: clean
	@echo "$(RED)🔥 Removing Docker images and persistent physical volumes...$(NC)"
	@docker volume rm $(VOLUME) 2>/dev/null || true
	@docker image prune -af
	@docker container prune -f
	@sudo rm -rf /home/$(USER)/data/database /home/$(USER)/data/wordpress 2>/dev/null || true
	@echo "$(GREEN)✅ Local persistent data removed safely.$(NC)"

create-env:
	@echo "$(BLUE)📝 Creating fresh .env file with <replace> values...$(NC)"
	@echo "DB_NAME=<replace>"                          >  $(SRCSDIR)/.env
	@echo "DB_USER=<replace>"                          >> $(SRCSDIR)/.env
	@echo                                              >> $(SRCSDIR)/.env
	@echo "# Wordpress related environment variables"  >> $(SRCSDIR)/.env
	@echo "DOMAIN_NAME=<replace>"                      >> $(SRCSDIR)/.env
	@echo "WP_TITLE=<replace>"                         >> $(SRCSDIR)/.env
	@echo "WP_ADMIN_USER=<replace>"                    >> $(SRCSDIR)/.env
	@echo "WP_ADMIN_EMAIL=<replace>"                   >> $(SRCSDIR)/.env
	@echo                                              >> $(SRCSDIR)/.env
	@echo "# Wordpress user"                           >> $(SRCSDIR)/.env
	@echo "WP_USER_NAME=<replace>"                     >> $(SRCSDIR)/.env
	@echo "WP_USER_EMAIL=<replace>"                    >> $(SRCSDIR)/.env
	@echo "WP_USER_PASSWORD=<replace>"                 >> $(SRCSDIR)/.env
	@echo "WP_USER_ROLE=<replace>"                     >> $(SRCSDIR)/.env
	@echo "$(GREEN)✅ srcs/.env file created.$(NC)"

secrets:
	@echo "$(BLUE)🔐 Creating secrets directory and placeholder password files...$(NC)"
	@mkdir -p secrets
	@echo "<replace>" > secrets/db_password.txt
	@echo "<replace>" > secrets/db_root_password.txt
	@echo "$(GREEN)✅ Secrets created: db_password.txt, db_root_password.txt$(NC)"


re: fclean up

rebuild: fclean all

help:
	@echo ""
	@echo "🛠️  Available Makefile commands:"
	@echo "  make ssl          - Generate SSL certificate for NGINX"
	@echo "  make create-env   - Create a new srcs/.env with <replace> values"
	@echo "  make secrets      - Create secrets/ folder with placeholder password files"
	@echo "  make up           - Build and start containers"
	@echo "  make down         - Stop and remove containers and volumes"
	@echo "  make start        - Start existing (stopped) containers"
	@echo "  make stop         - Stop running containers"
	@echo "  make clean        - Stop and remove containers + volumes"
	@echo "  make fclean       - Like clean + remove images and persistent files"
	@echo "  make nuke         - Like down but also removes orphans"
	@echo "  make re           - fclean + up"
	@echo "  make rebuild      - fclean + all (e.g. build SSL then up)"
	@echo ""


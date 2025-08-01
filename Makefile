NAME        := inception
SRCSDIR     := srcs
SECRETS		:= secrets
COMPOSE     := docker compose -f $(SRCSDIR)/docker-compose.yml
ENV         := --env-file $(SRCSDIR)/.env
VOLUME      := wordpress_data
SSL_DIR     := $(SRCSDIR)/requirements/nginx/tools

GREEN   := \033[1;32m
RED     := \033[1;31m
BLUE    := \033[1;34m
NC      := \033[0m

.PHONY: all up down start stop clean fclean rebuild re ssl nuke env secrets setup host

all: help

setup: host ssl env secrets

host:
	@grep -q "kabasolo.42.fr" /etc/hosts || echo "127.0.0.1 kabasolo.42.fr" | sudo tee -a /etc/hosts

ssl:
	@mkdir -p $(SSL_DIR)
	@>$(SSL_DIR)/nginx.key
	@>$(SSL_DIR)/nginx.crt
	@echo "$(BLUE)🔐 Creating SSL certificate...$(NC)"
	@openssl req -x509 -nodes -days 365 -subj "/C=CA/ST=QC/O=C Inc/CN=e.com" -newkey rsa:2048 \
		-keyout $(SSL_DIR)/nginx.key -out $(SSL_DIR)/nginx.crt
	@echo "$(GREEN)✅ SSL certificate created.$(NC)"

env:
	@echo "$(BLUE)📝 Creating fresh .env file with <replace> values...$(NC)"
	@echo "# Wordpress user"                           > $(SRCSDIR)/.env
	@echo "WP_USER_NAME=<replace>"                     >> $(SRCSDIR)/.env
	@echo "WP_USER_EMAIL=<replace>"                    >> $(SRCSDIR)/.env
	@echo "WP_USER_PASSWORD=<replace>"                 >> $(SRCSDIR)/.env
	@echo "WP_USER_ROLE=author"                        >> $(SRCSDIR)/.env
	@echo "$(GREEN)✅ srcs/.env file created.$(NC)"

secrets:
	@echo "$(BLUE)🔐 Creating secrets directory and placeholder password files...$(NC)"
	@mkdir -p secrets
	@echo "DB_NAME=wordpress"                          >  $(SECRETS)/credentials.txt
	@echo "DB_USER=wpuser"                             >> $(SECRETS)/credentials.txt
	@echo "DB_HOST=mariadb"                            >> $(SECRETS)/credentials.txt
	@echo                                              >> $(SECRETS)/credentials.txt
	@echo "DOMAIN_NAME=kabasolo.42.fr"                 >> $(SECRETS)/credentials.txt
	@echo "WP_TITLE=mySite"                            >> $(SECRETS)/credentials.txt
	@echo "WP_ADMIN_USER=<replace>"                    >> $(SECRETS)/credentials.txt
	@echo "WP_ADMIN_EMAIL=<replace>"                   >> $(SECRETS)/credentials.txt
	@echo "<replace>" > $(SECRETS)/db_password.txt
	@echo "<replace>" > $(SECRETS)/db_root_password.txt
	@echo "$(GREEN)✅ Secrets created: db_password.txt, db_root_password.txt$(NC)"

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
	@sudo rm -rf /home/$(USER)/data/web 2>/dev/null || true
	@sudo rm -rf /home/$(USER)/data/database /home/$(USER)/data/wordpress 2>/dev/null || true
	@echo "$(GREEN)✅ Local persistent data removed safely.$(NC)"

re: fclean up

rebuild: fclean all

help:
	@echo ""
	@echo "🏁  Automatic setup: 'you just gotta change the <replace> in the .env'"
	@echo "  make setup"
	@echo "👶  Individual setup steps:"
	@echo "  make host		   - Introduces 'kabasolo.42.fr' as a valid host to your machine"
	@echo "  make ssl          - Generate SSL certificate for NGINX"
	@echo "  make env          - Create a new srcs/.env with <replace> values"
	@echo "  make secrets      - Create secrets/ folder with placeholder password files"
	@echo ""
	@echo "🛠️  Available Makefile commands:"
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


NAME        := inception
SRCSDIR     := srcs
SECRETS     := secrets
COMPOSE     := docker compose -f $(SRCSDIR)/docker-compose.yml
ENV         := --env-file $(SRCSDIR)/.env
VOLUME      := wordpress_data
HOST        := kabasolo.42.fr

GREEN   := \033[1;32m
RED     := \033[1;31m
BLUE    := \033[1;34m
NC      := \033[0m

.PHONY: all up down start stop clean fclean rebuild re nuke env secrets setup host

all: help

setup: host env secrets

host:
	@grep -q "$(HOST)" /etc/hosts || echo "127.0.0.1 $(HOST)" | sudo tee -a /etc/hosts

env:
	@echo "$(BLUE)📝 Creating fresh .env file with <replace> values...$(NC)"
	@echo "DB_NAME=wordpress"   >  $(SRCSDIR)/.env
	@echo "DB_USER=wpuser"      >> $(SRCSDIR)/.env
	@echo "DB_HOST=mariadb"     >> $(SRCSDIR)/.env
	@echo "DOMAIN_NAME=$(HOST)" >> $(SRCSDIR)/.env
	@echo "WP_TITLE=mySite"     >> $(SRCSDIR)/.env
	@echo "WP_PORT=443"         >> $(SRCSDIR)/.env
	@echo "$(GREEN)✅ srcs/.env file created.$(NC)"

secrets:
	@echo "$(BLUE)🔐 Creating secrets directory and placeholder password files...$(NC)"
	@mkdir -p secrets
	@echo "WP_USER_NAME=kabasolo"                          >  $(SECRETS)/credentials.txt
	@echo "WP_USER_EMAIL=kolodbikaabasolo@gmail.com"       >> $(SECRETS)/credentials.txt
	@echo "WP_USER_PASSWORD=$$(openssl rand -base64 12)"   >> $(SECRETS)/credentials.txt
	@echo "WP_ADMIN_USER=koldo"                            >> $(SECRETS)/credentials.txt
	@echo "WP_ADMIN_EMAIL=kolodbikaabasolo@gmail.com"      >> $(SECRETS)/credentials.txt
	@echo "WP_ADMIN_PASSWORD=$$(openssl rand -base64 12)"  >> $(SECRETS)/credentials.txt
	@echo "$$(openssl rand -base64 16)"                    >  $(SECRETS)/db_root_password.txt
	@echo "$$(openssl rand -base64 16)"                    >  $(SECRETS)/db_password.txt
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
	@echo "🏁  Automatic setup:"
	@echo "  make setup        - You just gotta change the <replace> in the secrets"
	@echo ""
	@echo "👶  Individual setup steps:"
	@echo "  make host         - Introduces 'kabasolo.42.fr' as a valid host to your machine"
	@echo "  make env          - Create a new srcs/.env"
	@echo "  make secrets      - Create secrets/ folder with placeholders to replace"
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


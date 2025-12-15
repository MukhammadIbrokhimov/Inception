COMPOSE_FILE ?= srcs/docker-compose.yml

# Prefer Docker Compose v2 ("docker compose"), fall back to legacy ("docker-compose").
COMPOSE ?= docker compose
ifneq (, $(shell command -v docker-compose 2>/dev/null))
	COMPOSE := docker-compose
endif

build:
	@echo "Building the project..."
	@$(COMPOSE) -f $(COMPOSE_FILE) up --build

start:
	@echo "Starting the project..."
	@$(COMPOSE) -f $(COMPOSE_FILE) up

stop:
	@echo "Stopping the project..."
	@$(COMPOSE) -f $(COMPOSE_FILE) down

restart:
	@echo "Restarting the project..."
	@$(COMPOSE) -f $(COMPOSE_FILE) restart

rm:
	@echo "Removing the project..."
	@$(COMPOSE) -f $(COMPOSE_FILE) rm

ps:
	@echo "Listing the project..."
	@$(COMPOSE) -f $(COMPOSE_FILE) ps

logs:
	@echo "Listing the logs..."
	@$(COMPOSE) -f $(COMPOSE_FILE) logs

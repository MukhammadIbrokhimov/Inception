COMPOSE_FILE=srcs/docker-compose.yml

build:
	@echo "Building the project..."
	@docker compose -f $(COMPOSE_FILE) up --build

start:
	@echo "Starting the project..."
	@docker compose -f $(COMPOSE_FILE) up

stop:
	@echo "Stopping the project..."
	@docker compose -f $(COMPOSE_FILE) down

restart:
	@echo "Restarting the project..."
	@docker compose -f $(COMPOSE_FILE) restart

rm:
	@echo "Removing the project..."
	@docker compose -f $(COMPOSE_FILE) rm

ps:
	@echo "Listing the project..."
	@docker compose -f $(COMPOSE_FILE) ps

logs:
	@echo "Listing the logs..."
	@docker compose -f $(COMPOSE_FILE) logs

COMPOSE_FILE=srcs/docker-compose.yml
VOL_PATH=$(shell pwd)/data
DOCKER=VOL_PATH=$(VOL_PATH) docker compose -f $(COMPOSE_FILE)

DOMAIN=mukibrok.42.fr

build: setup-hosts secrets
	@echo "Creating directories..."
	mkdir -p $(VOL_PATH)/mariadb
	mkdir -p $(VOL_PATH)/wordpress
	@echo "Building the project..."
	@$(DOCKER) up --build

setup-hosts:
	@if grep -q "$(DOMAIN)" /etc/hosts; then \
		echo "$(DOMAIN) already in /etc/hosts"; \
	else \
		echo "Adding $(DOMAIN) to /etc/hosts"; \
		echo "127.0.0.1 $(DOMAIN)" | sudo tee -a /etc/hosts; \
	fi

start:
	@echo "Starting the project..."
	@$(DOCKER) up

stop:
	@echo "Stopping the project..."
	@$(DOCKER) down

restart:
	@echo "Restarting the project..."
	@$(DOCKER) restart

rm:
	@echo "Removing the project..."
	@$(DOCKER) rm

ps:
	@echo "Listing the project..."
	@$(DOCKER) ps

logs:
	@echo "Listing the logs..."
	$(DOCKER) logs

secrets:
	@echo "Creating secrets..."
	@mkdir -p secrets
	@echo "mukibrok2002" > secrets/db_root_password.txt
	@echo "wpuser2002" > secrets/db_password.txt
	@echo "mukibrok2002" > secrets/credentials.txt
	@echo "Secrets created successfully"

delete:
	@echo "Deleting secrets..."
	@rm -rf secrets
	@echo "Secrets deleted successfully"

clean:
	@echo "Cleaning the project..."
	@$(DOCKER) down --volumes
	@docker container prune -f
	@docker network prune -f
	@docker volume prune -f
	@docker image prune -af
	@rm -rf ./data
	@echo "Project cleaned successfully"

fclean:
	@echo "Fully cleaning the project..."
	@$(DOCKER) down --volumes
	@docker container prune -f
	@docker network prune -f
	@docker volume prune -f
	@docker image prune -af
	@rm -rf ./data
	@rm -rf secrets
	@echo "Project fully cleaned successfully"

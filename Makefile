build:
	@echo "Building the project..."
	@docker-compose up --build

start:
	@echo "Starting the project..."
	@docker-compose up

stop:
	@echo "Stopping the project..."
	@docker-compose down

restart:
	@echo "Restarting the project..."
	@docker-compose restart

rm:
	@echo "Removing the project..."
	@docker-compose rm

ps:
	@echo "Listing the project..."
	@docker-compose ps

logs:
	@echo "Listing the logs..."
	@docker-compose logs

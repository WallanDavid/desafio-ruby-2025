.PHONY: help setup up down test lint clean

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

setup: ## Build and prepare the application
	docker compose build
	docker compose run --rm web bin/rails db:create
	docker compose run --rm web bin/rails db:migrate
	docker compose run --rm web bin/rails db:seed

up: ## Start all services
	docker compose up -d

down: ## Stop all services
	docker compose down

logs: ## Show logs from all services
	docker compose logs -f

test: ## Run tests
	docker compose run --rm web bundle exec rspec

lint: ## Run linter
	docker compose run --rm web bundle exec rubocop

console: ## Open Rails console
	docker compose run --rm web bundle exec rails console

shell: ## Open shell in web container
	docker compose run --rm web bash

clean: ## Clean up containers and volumes
	docker compose down -v
	docker system prune -f

reset: ## Reset database and restart services
	docker compose down
	docker compose run --rm web bin/rails db:drop db:create db:migrate
	docker compose up -d

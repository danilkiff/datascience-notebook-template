.PHONY: up up-gpu down build logs clean ps

up: ## Start all services
	docker compose up --detach --build

up-gpu: ## Start all services with GPU support
	docker compose -f docker-compose.yaml -f docker-compose.gpu.yaml up --detach --build

down: ## Stop all services
	docker compose down

build: ## Rebuild images without cache
	docker compose build --no-cache

logs: ## Tail logs from all services
	docker compose logs --follow

ps: ## Show running services
	docker compose ps

clean: ## Stop services and remove volumes
	docker compose down --volumes --remove-orphans

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help

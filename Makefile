# SPDX-License-Identifier: Unlicense
.PHONY: up up-gpu up-monitoring up-orchestration up-serving down build logs clean ps lock init train test dvc-push dvc-pull template-test

up: ## Start all services
	docker compose up --detach --build

up-gpu: ## Start all services with GPU support
	docker compose -f docker-compose.yaml -f docker-compose.gpu.yaml up --detach --build

up-monitoring: ## Start all services with monitoring
	docker compose --profile monitoring up --detach --build

up-orchestration: ## Start all services with Prefect
	docker compose --profile orchestration up --detach --build

up-serving: ## Start all services with model serving
	docker compose --profile serving up --detach --build

down: ## Stop all services (including profile services)
	docker compose --profile '*' down

build: ## Rebuild images without cache
	docker compose build --no-cache

logs: ## Tail logs from all services
	docker compose logs --follow

ps: ## Show running services
	docker compose ps

lock: ## Regenerate pinned requirements/*.txt from *.in
	uv pip compile requirements/jupyter.in -o requirements/jupyter.txt --python-version 3.12 -c requirements/jupyter.constraints --no-header
	uv pip compile requirements/mlflow.in -o requirements/mlflow.txt --python-version 3.12 --no-header
	uv pip compile requirements/prefect.in -o requirements/prefect.txt --python-version 3.12 --no-header
	uv pip compile requirements/serving.in -o requirements/serving.txt --python-version 3.12 --no-header

init: ## Generate .env with random passwords
	bash scripts/init-env.sh

train: ## Run training script inside Jupyter container
	docker compose exec jupyter python src/train.py

test: ## Run pytest inside Jupyter container
	docker compose exec jupyter pytest src/tests/ -v

dvc-push: ## Push DVC-tracked data to MinIO
	docker compose exec jupyter dvc push

dvc-pull: ## Pull DVC-tracked data from MinIO
	docker compose exec jupyter dvc pull

template-test: ## Test copier template generation
	rm -rf /tmp/copier-test && uvx copier copy . /tmp/copier-test --defaults --trust
	cd /tmp/copier-test && cp .env.example .env && docker compose config > /dev/null
	rm -rf /tmp/copier-test

clean: ## Stop services and remove volumes
	docker compose down --volumes --remove-orphans

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help

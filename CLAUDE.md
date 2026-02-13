# CLAUDE.md

## Project overview

Docker-first DS/ML template: JupyterLab + MLflow + PostgreSQL + MinIO.
No Python source code in the repo — only infrastructure files.
User code lives in `workspace/` (gitignored contents, tracked structure).

## Architecture

Five Docker Compose services with health-checked startup order:

```
s3 (MinIO) ──healthy──▶ init_s3 (bucket setup) ──completed──┐
postgres ──healthy──────────────────────────────────────────┤
                                                            ▼
                                                          mlflow ──healthy──▶ jupyter
```

Two networks: `backend` (postgres, minio, mlflow) and `frontend` (jupyter, mlflow).
GPU support is a separate overlay: `docker-compose.gpu.yaml`.

## Key files

- `docker-compose.yaml` — service orchestration, single source of truth
- `docker-compose.gpu.yaml` — NVIDIA GPU overlay (shm_size: 8g + devices)
- `Dockerfile.jupyter` — base: `quay.io/jupyter/scipy-notebook`, adds fastai + mlflow + boto3
- `Dockerfile.mlflow` — base: `python:3.12-slim`, adds mlflow + psycopg2 + boto3
- `requirements/jupyter.in` and `requirements/mlflow.in` — pinned Python deps
- `.env.example` — all configurable variables with defaults
- `Makefile` — common commands (`make help` to list)

## Common commands

```
make up        # start stack (CPU)
make up-gpu    # start stack with NVIDIA GPU
make down      # stop
make clean     # stop + remove volumes
make logs      # tail all service logs
make build     # rebuild images without cache
```

## Conventions

- All Docker images and pip packages must be version-pinned
- Environment variables go through `.env`, never hardcoded in compose
- `env_file:` is not used — variables are passed explicitly via `environment:` map
- Internal services (postgres, minio API) must not expose ports to host
- Only Jupyter (8888), MLflow UI (MLFLOW_PORT), MinIO Console (MINIO_CONSOLE_PORT) are exposed
- Commit messages: imperative mood, short first line (see git log)

## Linting

CI runs: hadolint (Dockerfiles), markdownlint (*.md), gitleaks (secrets), actionlint (workflows), compose validation, smoke-test (full stack up).
Local: pre-commit hooks — nbstripout + ruff.

## Adding Python dependencies

1. Add pinned package to `requirements/jupyter.in` or `requirements/mlflow.in`
2. Run `make build`

## Do not

- Put secrets in tracked files (`.env` is gitignored)
- Add `env_file:` back to docker-compose services
- Expose postgres or minio API ports to host
- Hardcode `shm_size` — use `SHM_SIZE` env var (default 2g, GPU override sets 8g)
- Commit notebook outputs — nbstripout pre-commit hook handles this

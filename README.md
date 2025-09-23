# JupyterLab Data Science Environment

A GPU-ready environment for data science and deep learning experiments with
JupyterLab, Fast.ai, and MLflow tracking server (with MinIO + PostgreSQL).

* **Jupyter** for interactive dev & training (GPU-ready).
* **MLflow** as tracking/UI.
* **PostgreSQL** as MLflow backend store (experiments, params, metrics).
* **MinIO (S3)** as artifact store (models, plots, notebooks).
* **init\_s3** as one-time bucket initializer.

## Topology

```mermaid
sequenceDiagram
  participant S3 as s3 [mlflow_s3]
  participant Init as init_s3 [mlflow_init_s3]
  participant PG as postgres [mlflow_postgres]
  participant MF as mlflow [mlflow_server]
  participant NB as jupyter [jupyter]

  Note over S3,NB: docker compose up --detach --build

  S3->>S3: healthcheck (ready on :9000)
  PG->>PG: pg_isready
  S3-->>Init: service_healthy
  Init->>S3: mc mb -p <bucket> + enable versioning
  Init-->>MF: service_completed_successfully
  PG-->>MF: service_healthy
  MF->>PG: connect (backend URI)
  MF->>S3: ping (artifact root)
  MF-->>NB: service_healthy
  NB->>MF: log params/metrics/artifacts
  NB->>S3: direct S3 operations if needed
```

## Data Flow

1. Notebook runs in **Jupyter**.
2. Code calls MLflow client (`mlflow.log_*` / `autolog()`).
3. **MLflow** writes metadata to **Postgres**.
4. **MLflow** uploads artifacts to **MinIO** under `s3://$MINIO_BUCKET/...`.
5. You inspect runs in MLflow UI; raw artifacts visible via MinIO Console.

## Volumes

* `postgres_data` → Postgres cluster data
* `minio_data` → MinIO object store
* `./workspace` ↔ `/home/<NB_USER>` (your notebooks/code)

> Back up by snapshotting volumes + the workspace directory.

## Minimal Code Contracts

Notebook snippet (already preconfigured via env):

```python
import mlflow, os
mlflow.set_experiment("notebooks")
with mlflow.start_run(run_name="demo"):
    mlflow.log_param("lr", 3e-4)
    mlflow.log_metric("loss", 0.12)
    mlflow.log_artifact("some_output.txt")
```

## Features

* JupyterLab with pre-installed data science libraries (pandas, numpy,
  matplotlib, scikit-learn)
* MLflow tracking server with MinIO (S3) and PostgreSQL backend
* Fast.ai deep learning framework
* NVIDIA GPU support (CUDA)
* Pre-configured workspace directory
* 8GB shared memory allocation

## Prerequisites

* Docker and Docker Compose
* NVIDIA GPU with drivers (optional)
* NVIDIA Container Toolkit (for GPU support)

## Quick Start

* Clone this repository
* Copy `.env.example` to `.env` and adjust for your needs.
   Then start the container:

```bash
docker-compose up --build --detach
```

## Access

* JupyterLab    - http://localhost:8888
* MLflow UI     - http://localhost:5050
* MinIO console - http://localhost:9001 (credentials from `.env`)

## GPU Usage

For GPU support, ensure:

1. NVIDIA drivers are installed on the host
2. NVIDIA Container Toolkit is configured
3. GPU devices are available in Docker

Verify GPU access in JupyterLab:

```python
import torch
print(torch.cuda.is_available())
```

## Project Structure

```text
.
├── docker-compose.yaml    # Orchestration of all services
├── .env                   # Environment variables (edit here)
├── Dockerfile.jupyter     # JupyterLab + fastai + mlflow client
├── Dockerfile.mlflow      # MLflow tracking server
└── workspace/             # User working directory (mounted in Jupyter)
```

## Security Notes

Default configuration disables authentication (for development only).
For production use:

* Set `JUPYTER_TOKEN` environment variable
* Use HTTPS encryption
* Enable authentication
* Restrict network access

## Customization

Add packages to Dockerfile:

```Dockerfile
RUN pip install --user --no-cache-dir your-package-name
```

Rebuild the container after changes:

```bash
docker-compose build --no-cache
```

## Troubleshooting

### Permission issues

```bash
sudo chown -R $USER:$USER workspace/
```

### GPU not available

Make sure the NVIDIA driver is installed and `nvidia-smi` works on the host.

Verify that [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/)
is installed and integrated with Docker:

```bash
sudo nvidia-ctk runtime configure --runtime=docker --set-as-default
sudo systemctl restart docker
```

Docker 25+ supports CDI but device specs must be generated first:

```bash
sudo nvidia-ctk cdi generate --output=/etc/cdi/nvidia.yaml
sudo systemctl restart docker
```

After that, this will work the same as `--gpus all`:

```bash
docker run --rm --device=nvidia.com/gpu=all nvidia/cuda:12.4.1-base-ubuntu22.04 nvidia-smi
```

### Port conflict

Change port mapping in docker-compose.yaml:

```yaml
ports:
  - 8889:8888
```

## License

This project is provided for educational and research purposes
under the Unlicense terms.

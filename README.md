# JupyterLab Data Science Environment

A GPU-ready container for data science and deep learning experiments with JupyterLab, Fast.ai, and popular scientific Python libraries.

## Features

- JupyterLab with pre-installed data science libraries (pandas, numpy, matplotlib, scikit-learn)
- Fast.ai deep learning framework
- NVIDIA GPU support (CUDA)
- Pre-configured workspace directory
- 8GB shared memory allocation

## Prerequisites

- Docker and Docker Compose
- NVIDIA GPU with drivers (optional)
- NVIDIA Container Toolkit (for GPU support)

## Quick Start

1. Clone this repository
2. Start the container:

```bash
docker-compose up -d
```

3. Access JupyterLab at: `http://localhost:8888`

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

```
.
├── docker-compose.yaml   # Container orchestration
├── Dockerfile            # Container definition
└── workspace/            # Working directory
```

## Security Notes

Default configuration disables authentication (for development only). For production use:

- Set `JUPYTER_TOKEN` environment variable
- Use HTTPS encryption
- Enable authentication
- Restrict network access

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

1. **Permission issues**:

```bash
sudo chown -R $USER:$USER workspace/
```

2. **GPU not available**:

Make sure the NVIDIA driver is installed and `nvidia-smi` works on the host.

Verify that [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/) is installed and integrated with Docker:

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

3. **Port conflict**:

Change port mapping in docker-compose.yaml:

```yaml
ports:
  - 8889:8888
```

## License

This project is provided for educational and research purposes under the Unlicense terms.

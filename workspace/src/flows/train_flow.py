# SPDX-License-Identifier: Unlicense
"""Example Prefect flow wrapping the training pipeline."""

from prefect import flow, task


@task
def load_data():
    """Load dataset. Replace with actual data loading logic."""
    print("Loading data...")
    return {"x": "data", "y": "labels"}


@task
def train_model(data):
    """Train model. Replace with actual training logic."""
    print(f"Training model on {len(data)} items...")
    return {"accuracy": 0.95}


@task
def log_results(metrics):
    """Log results to MLflow. Replace with actual logging."""
    print(f"Logging metrics: {metrics}")


@flow(name="training-pipeline")
def training_pipeline():
    """End-to-end training pipeline."""
    data = load_data()
    metrics = train_model(data)
    log_results(metrics)
    return metrics


if __name__ == "__main__":
    training_pipeline()

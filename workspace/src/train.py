# SPDX-License-Identifier: Unlicense
"""Training script template with Hydra config and MLflow tracking."""

import random

import hydra
import mlflow
import numpy as np
import torch
from omegaconf import DictConfig


def set_seed(seed: int) -> None:
    """Fix random seed for reproducibility."""
    random.seed(seed)
    np.random.seed(seed)
    torch.manual_seed(seed)
    if torch.cuda.is_available():
        torch.cuda.manual_seed_all(seed)


def load_data(cfg: DictConfig) -> tuple:
    """Load and preprocess data. Replace with your dataset logic."""
    x = np.random.randn(100, 10).astype(np.float32)
    y = (x[:, 0] > 0).astype(np.float32)
    return x, y


def build_model(cfg: DictConfig) -> torch.nn.Module:
    """Build model. Replace with your architecture."""
    return torch.nn.Sequential(
        torch.nn.Linear(10, 32),
        torch.nn.ReLU(),
        torch.nn.Linear(32, 1),
        torch.nn.Sigmoid(),
    )


def train_model(
    model: torch.nn.Module,
    x: np.ndarray,
    y: np.ndarray,
    cfg: DictConfig,
) -> float:
    """Train loop. Returns final loss value."""
    optimizer = torch.optim.Adam(model.parameters(), lr=cfg.model.lr)
    loss_fn = torch.nn.BCELoss()
    x_t = torch.from_numpy(x)
    y_t = torch.from_numpy(y).unsqueeze(1)

    model.train()
    final_loss = 0.0
    for epoch in range(cfg.model.epochs):
        optimizer.zero_grad()
        preds = model(x_t)
        loss = loss_fn(preds, y_t)
        loss.backward()
        optimizer.step()
        final_loss = loss.item()

    return final_loss


@hydra.main(config_path="config", config_name="train", version_base="1.3")
def main(cfg: DictConfig) -> None:
    set_seed(cfg.seed)

    mlflow.set_experiment(cfg.mlflow.experiment_name)
    with mlflow.start_run():
        mlflow.log_params(
            {
                "seed": cfg.seed,
                "lr": cfg.model.lr,
                "epochs": cfg.model.epochs,
                "batch_size": cfg.model.batch_size,
            }
        )

        x, y = load_data(cfg)
        model = build_model(cfg)
        final_loss = train_model(model, x, y, cfg)

        mlflow.log_metric("final_loss", final_loss)
        print(f"Training complete. Final loss: {final_loss:.4f}")


if __name__ == "__main__":
    main()

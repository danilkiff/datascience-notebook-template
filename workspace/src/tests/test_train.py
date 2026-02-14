# SPDX-License-Identifier: Unlicense
"""Unit tests for the training template."""

import numpy as np
from omegaconf import OmegaConf

from train import build_model, load_data, set_seed, train_model


def _cfg(**overrides):
    """Create a minimal config for testing."""
    defaults = {
        "seed": 42,
        "data": {"path": "data/raw"},
        "model": {"lr": 0.01, "epochs": 2, "batch_size": 32},
        "mlflow": {"experiment_name": "test"},
    }
    defaults.update(overrides)
    return OmegaConf.create(defaults)


def test_set_seed_deterministic():
    set_seed(42)
    a = np.random.rand(5)
    set_seed(42)
    b = np.random.rand(5)
    np.testing.assert_array_equal(a, b)


def test_load_data_shape():
    cfg = _cfg()
    x, y = load_data(cfg)
    assert x.shape == (100, 10)
    assert y.shape == (100,)


def test_build_model_forward():
    cfg = _cfg()
    model = build_model(cfg)
    import torch

    out = model(torch.randn(4, 10))
    assert out.shape == (4, 1)


def test_train_model_reduces_loss():
    cfg = _cfg()
    set_seed(cfg.seed)
    x, y = load_data(cfg)
    model = build_model(cfg)
    loss = train_model(model, x, y, cfg)
    assert isinstance(loss, float)
    assert loss < 1.0

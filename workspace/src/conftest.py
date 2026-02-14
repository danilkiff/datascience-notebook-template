# SPDX-License-Identifier: Unlicense
"""Shared pytest fixtures."""

import os

import pytest


@pytest.fixture(autouse=True)
def _isolate_mlflow(tmp_path, monkeypatch):
    """Route MLflow to a temporary directory so tests don't need a server."""
    monkeypatch.setenv("MLFLOW_TRACKING_URI", str(tmp_path / "mlruns"))
    monkeypatch.delenv("MLFLOW_S3_ENDPOINT_URL", raising=False)

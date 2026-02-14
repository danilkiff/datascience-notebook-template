# SPDX-License-Identifier: Unlicense
"""Smoke tests for the MLflow model serving endpoint.

These tests are designed to run against a live serving container.
Use: pytest src/tests/test_serving.py -v
Requires: make up-serving (with a registered model in MLflow).
"""

import os

import pytest
import requests

SERVING_URL = os.getenv("SERVING_URL", "http://localhost:8080")


@pytest.fixture()
def serving_url():
    """Return the serving endpoint URL, skip if unreachable."""
    try:
        resp = requests.get(f"{SERVING_URL}/health", timeout=5)
        resp.raise_for_status()
    except (requests.ConnectionError, requests.Timeout):
        pytest.skip("Serving endpoint not reachable")
    return SERVING_URL


def test_health(serving_url):
    """Health endpoint returns 200."""
    resp = requests.get(f"{serving_url}/health", timeout=5)
    assert resp.status_code == 200


def test_ping(serving_url):
    """Ping endpoint returns 200."""
    resp = requests.get(f"{serving_url}/ping", timeout=5)
    assert resp.status_code == 200

#!/usr/bin/env bash
# SPDX-License-Identifier: Unlicense
# Entrypoint for the MLflow model serving container.
# Waits for the MLflow tracking server, then serves the specified model.
set -euo pipefail

MLFLOW_TRACKING_URI="${MLFLOW_TRACKING_URI:?MLFLOW_TRACKING_URI must be set}"
MODEL_URI="${SERVING_MODEL_URI:?SERVING_MODEL_URI must be set (e.g. models:/my-model/1)}"
PORT="${SERVING_PORT_INTERNAL:-8080}"

echo "Waiting for MLflow tracking server at ${MLFLOW_TRACKING_URI} ..."
until wget -qO- "${MLFLOW_TRACKING_URI}/" >/dev/null 2>&1; do
    sleep 2
done
echo "MLflow tracking server is ready."

echo "Serving model: ${MODEL_URI}"
exec mlflow models serve \
    --model-uri "${MODEL_URI}" \
    --host 0.0.0.0 \
    --port "${PORT}" \
    --no-conda

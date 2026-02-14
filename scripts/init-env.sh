#!/usr/bin/env bash
# SPDX-License-Identifier: Unlicense
set -euo pipefail

ENV_FILE=".env"
EXAMPLE_FILE=".env.example"

if [ -f "$ENV_FILE" ] && [ "${1:-}" != "--force" ]; then
    echo "⚠  $ENV_FILE already exists. Use --force to overwrite."
    exit 1
fi

if [ ! -f "$EXAMPLE_FILE" ]; then
    echo "Error: $EXAMPLE_FILE not found."
    exit 1
fi

generate_password() {
    openssl rand -base64 18 | tr -d '/+=' | head -c 24
}

JUPYTER_TOKEN=$(generate_password)
MINIO_PASSWORD=$(generate_password)
POSTGRES_PASSWORD=$(generate_password)

sed \
    -e "s/^JUPYTER_TOKEN=.*/JUPYTER_TOKEN=${JUPYTER_TOKEN}/" \
    -e "s/^MINIO_ROOT_PASSWORD=.*/MINIO_ROOT_PASSWORD=${MINIO_PASSWORD}/" \
    -e "s/^POSTGRES_PASSWORD=.*/POSTGRES_PASSWORD=${POSTGRES_PASSWORD}/" \
    "$EXAMPLE_FILE" > "$ENV_FILE"

# Verify no placeholder passwords remain
if grep -qE '^(JUPYTER_TOKEN|MINIO_ROOT_PASSWORD|POSTGRES_PASSWORD)=(changeme|password)$' "$ENV_FILE"; then
    echo "Error: placeholder passwords still present in $ENV_FILE"
    exit 1
fi

echo "Created $ENV_FILE with generated passwords."

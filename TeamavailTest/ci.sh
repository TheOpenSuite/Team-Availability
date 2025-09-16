#!/bin/bash
set -euo pipefail

IMAGE_NAME="teamavail:local"
COMPOSE_FILE="docker-compose.yml"
NPM_CMD="npm"

echo "### CI START"

# Checks
if ! command -v docker >/dev/null 2>&1; then
  echo "ERROR: Download Docker as Docker isn't installed" >&2
  exit 1
fi

if ! command -v "$NPM_CMD" >/dev/null 2>&1; then
  echo "ERROR: Install Node.js/npm as it isn't installed" >&2
  exit 1
fi

# Installing Dependencies
if [ -f package.json ]; then
  echo "### Installing Node.js dependencies"
  "$NPM_CMD" ci
else
  echo "No package.json found. Skipping npm steps."
  exit 0
fi

# Lint
echo "### Running lint"
if "$NPM_CMD" run -s lint &>/dev/null; then
  "$NPM_CMD" run lint
else
  echo "No script found, skipping this step"
fi

# Formatting
echo "### Running format"
if "$NPM_CMD" run -s format &>/dev/null; then
  "$NPM_CMD" run format
else
  echo "No script found, skipping this step"
fi

# Testing
echo "### Running tests"
if "$NPM_CMD" run -s test &>/dev/null; then
  "$NPM_CMD" run test
else
  echo "No script found, skipping this step"
fi

# Docker
echo "### Building Docker image: $IMAGE_NAME"
docker build -t "$IMAGE_NAME" .

if [ -f "$COMPOSE_FILE" ]; then
  echo "### Starting with docker compose"
  docker compose -f "$COMPOSE_FILE" up -d --build
  echo "### Status:"
  docker ps --filter "ancestor=$IMAGE_NAME" --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"
else
  echo "No docker-compose.yml found. Built image is available as $IMAGE_NAME"
fi

echo "### CI COMPLETE"

#!/bin/bash

# Graphiti MCP Server Startup Script
# Part of Docker MCP Server Migration with Latest Graphiti
# Implements Docker daemon polling with 2-second intervals

set -e  # Exit on error

LOG_FILE="$HOME/Library/Logs/graphiti-mcp.log"
PID_FILE="$HOME/Library/Application Support/graphiti-mcp.pid"

# Create log directory if needed
mkdir -p "$(dirname "$LOG_FILE")"
mkdir -p "$(dirname "$PID_FILE")"

# Log with timestamp
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [start_graphiti] $1" | tee -a "$LOG_FILE"
}

log "Starting Graphiti MCP Server..."

# Change to the correct working directory
cd "/Users/jiehoonk/DevHub/sideprojects/graphiti/mcp_server"

# Wait for Docker daemon to be ready
log "Waiting for Docker daemon to be ready..."
while ! docker info > /dev/null 2>&1; do
    log "Docker daemon not ready, waiting 2 seconds..."
    sleep 2
done
log "Docker daemon is ready"

# Stop existing services if running
log "Stopping existing Docker services..."
docker-compose down --remove-orphans || true

# Start services
log "Starting Docker Compose services..."
docker-compose up --build -d

# Wait for services to be healthy
log "Waiting for services to be healthy..."
max_attempts=30
attempt=1

while [ $attempt -le $max_attempts ]; do
    if docker-compose ps | grep -q "healthy"; then
        log "Services are healthy"
        break
    fi

    if [ $attempt -eq $max_attempts ]; then
        log "ERROR: Services did not become healthy within expected time"
        docker-compose logs
        exit 1
    fi

    log "Attempt $attempt/$max_attempts: Services not yet healthy, waiting..."
    sleep 5
    attempt=$((attempt + 1))
done

# Store PID for potential cleanup
echo $$ > "$PID_FILE"

log "Graphiti MCP Server started successfully"

# Keep the script running to maintain the LaunchAgent
# This allows proper cleanup on termination
trap 'log "Received termination signal, stopping services..."; docker-compose down; rm -f "$PID_FILE"; exit 0' TERM INT

# Monitor services in the background
while true; do
    if ! docker-compose ps | grep -q "Up"; then
        log "WARNING: Some services are not running, attempting restart..."
        docker-compose up -d
    fi
    sleep 30
done
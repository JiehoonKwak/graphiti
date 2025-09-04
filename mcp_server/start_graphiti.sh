#!/bin/bash

# Graphiti MCP Server Auto-Start Script
# Robust wrapper for launching Graphiti with Neo4j Enterprise

set -e  # Exit on error

# Configuration
PROJECT_DIR="/Users/jiehoonk/DevHub/sideprojects/agent-tools/graphiti/mcp_server"
LOG_DIR="$HOME/Library/Logs/graphiti"
LOG_FILE="$LOG_DIR/graphiti-autostart.log"
PID_FILE="$LOG_DIR/graphiti.pid"

# Create log directory if it doesn't exist
mkdir -p "$LOG_DIR"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Cleanup function
cleanup() {
    log "Stopping Graphiti containers..."
    cd "$PROJECT_DIR" && docker-compose -f docker-compose-sse.yml down || true
    rm -f "$PID_FILE"
    exit 0
}

# Set trap for cleanup
trap cleanup TERM INT

log "Starting Graphiti MCP Server..."

# Check if already running
if [ -f "$PID_FILE" ] && kill -0 $(cat "$PID_FILE") 2>/dev/null; then
    log "Graphiti is already running (PID: $(cat $PID_FILE))"
    exit 0
fi

# Save PID
echo $$ > "$PID_FILE"

# Change to project directory
cd "$PROJECT_DIR" || {
    log "ERROR: Cannot access project directory: $PROJECT_DIR"
    exit 1
}

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    log "Waiting for Docker to start..."
    for i in {1..30}; do
        if docker info >/dev/null 2>&1; then
            log "Docker is ready"
            break
        fi
        if [ $i -eq 30 ]; then
            log "ERROR: Docker did not start within 30 seconds"
            exit 1
        fi
        sleep 1
    done
fi

# Create Neo4j data directories if they don't exist
log "Ensuring Neo4j data directories exist..."
mkdir -p ~/neo4j-data/graphiti/{data,logs,import,plugins}
chmod -R 755 ~/neo4j-data/graphiti/

# Load environment variables
if [ -f ".env" ]; then
    export $(grep -v '^#' .env | xargs)
    log "Loaded environment variables from .env"
else
    log "WARNING: .env file not found, using defaults"
fi

# Start containers
log "Starting Docker containers..."
if docker-compose -f docker-compose-sse.yml up -d; then
    log "Containers started successfully"
else
    log "ERROR: Failed to start containers"
    cleanup
    exit 1
fi

# Health check function
wait_for_services() {
    log "Waiting for services to be healthy..."
    
    # Wait for Neo4j
    for i in {1..60}; do
        if curl -f http://localhost:7474 >/dev/null 2>&1; then
            log "Neo4j is healthy"
            break
        fi
        if [ $i -eq 60 ]; then
            log "ERROR: Neo4j did not become healthy within 60 seconds"
            return 1
        fi
        sleep 1
    done
    
    # Wait for MCP server
    for i in {1..30}; do
        if curl -s http://localhost:8000/sse | head -1 >/dev/null 2>&1; then
            log "MCP server is healthy"
            return 0
        fi
        if [ $i -eq 30 ]; then
            log "ERROR: MCP server did not become healthy within 30 seconds"
            return 1
        fi
        sleep 1
    done
}

# Wait for services
if wait_for_services; then
    log "All services are running and healthy"
    log "Neo4j Browser: http://localhost:7474"
    log "MCP SSE Endpoint: http://localhost:8000/sse"
else
    log "ERROR: Services failed to start properly"
    cleanup
    exit 1
fi

# Keep the script running and monitor services
log "Monitoring services (PID: $$)..."
while true; do
    # Check if containers are still running
    if ! docker-compose -f docker-compose-sse.yml ps | grep -q "Up"; then
        log "ERROR: One or more containers stopped unexpectedly"
        log "Attempting to restart..."
        docker-compose -f docker-compose-sse.yml up -d
        wait_for_services
    fi
    
    sleep 30  # Check every 30 seconds
done
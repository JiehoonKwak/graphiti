#!/bin/bash

# Graphiti MCP Server Health Check Script
# Part of Docker MCP Server Migration with Latest Graphiti
# Validates service health for monitoring and troubleshooting

set -e  # Exit on error

# Configuration
NEO4J_URL="http://localhost:7474"
MCP_URL="http://localhost:8000"
TIMEOUT=10

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Log with timestamp and color
log() {
    local level=$1
    local message=$2
    local color=""

    case $level in
        "ERROR") color=$RED ;;
        "SUCCESS") color=$GREEN ;;
        "WARNING") color=$YELLOW ;;
        *) color=$NC ;;
    esac

    echo -e "${color}$(date '+%Y-%m-%d %H:%M:%S') [$level] $message${NC}"
}

# Check if a service is responding
check_service() {
    local name=$1
    local url=$2

    if curl -s --max-time $TIMEOUT "$url" > /dev/null 2>&1; then
        log "SUCCESS" "$name is healthy at $url"
        return 0
    else
        log "ERROR" "$name is not responding at $url"
        return 1
    fi
}

# Check Docker services status
check_docker_services() {
    log "INFO" "Checking Docker Compose services..."

    cd "/Users/jiehoonk/DevHub/sideprojects/graphiti/mcp_server"

    if ! docker-compose ps > /dev/null 2>&1; then
        log "ERROR" "Docker Compose is not running or accessible"
        return 1
    fi

    # Get service status
    local services_output
    services_output=$(docker-compose ps --format table 2>/dev/null)

    if echo "$services_output" | grep -q "Up"; then
        log "SUCCESS" "Docker Compose services are running"
    else
        log "ERROR" "Docker Compose services are not running"
        echo "$services_output"
        return 1
    fi

    return 0
}

# Main health check
main() {
    log "INFO" "Starting Graphiti MCP Server health check..."

    local exit_code=0

    # Check Docker services
    if ! check_docker_services; then
        exit_code=1
    fi

    # Check Neo4j health
    if ! check_service "Neo4j" "$NEO4J_URL"; then
        exit_code=1
    fi

    # Check MCP server health
    if ! check_service "MCP Server" "$MCP_URL"; then
        exit_code=1
    fi

    # Additional checks if services are running
    if [ $exit_code -eq 0 ]; then
        log "INFO" "All services are healthy - performing additional checks..."

        # Check if Neo4j is actually ready (not just responding)
        if curl -s --max-time $TIMEOUT "$NEO4J_URL/db/data/" | grep -q "neo4j_version" > /dev/null 2>&1; then
            log "SUCCESS" "Neo4j database is fully ready"
        else
            log "WARNING" "Neo4j is responding but may not be fully initialized"
        fi

        # Check if MCP server is responding to health endpoint
        if curl -s --max-time $TIMEOUT "$MCP_URL/health" > /dev/null 2>&1; then
            log "SUCCESS" "MCP server health endpoint is responding"
        else
            log "WARNING" "MCP server is up but health endpoint not available"
        fi

        log "SUCCESS" "Health check completed successfully"
    else
        log "ERROR" "Health check failed - one or more services are not healthy"
    fi

    return $exit_code
}

# Handle script arguments
case "${1:-check}" in
    "check")
        main
        ;;
    "monitor")
        log "INFO" "Starting continuous health monitoring (Ctrl+C to stop)..."
        while true; do
            main
            echo "---"
            sleep 30
        done
        ;;
    "help"|"-h"|"--help")
        echo "Usage: $0 [check|monitor|help]"
        echo "  check    - Run single health check (default)"
        echo "  monitor  - Run continuous monitoring"
        echo "  help     - Show this help message"
        ;;
    *)
        echo "Unknown option: $1"
        echo "Use '$0 help' for usage information"
        exit 1
        ;;
esac
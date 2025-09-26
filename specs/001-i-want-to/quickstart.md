# Quick Start: Docker MCP Server Migration

## Prerequisites Verification

Before starting the migration, verify these requirements:

```bash
# Check Docker is installed and running
docker --version
docker info

# Check uv package manager is available
uv --version

# Verify current directory is mcp_server
pwd
# Should show: /Users/jiehoonk/DevHub/sideprojects/graphiti/mcp_server

# Check existing configuration files
ls -la .env docker-compose.yml Dockerfile
```

## Pre-Migration Backup

Create backups of existing configuration:

```bash
# Backup existing configuration
cp .env .env.backup.$(date +%Y%m%d)
cp docker-compose.yml docker-compose.yml.backup
cp /Users/jiehoonk/Library/LaunchAgents/com.jiehoonk.graphiti-mcp.plist /tmp/launchagent.backup.plist

# Verify Neo4j data volumes exist
docker volume ls | grep neo4j
```

## Migration Steps

### 1. Update Docker Compose Configuration

```bash
# Stop existing services
docker-compose down

# Update docker-compose.yml with latest versions
# (Implementation will modify existing file)

# Update .env with model compatibility settings
# (Implementation will preserve existing values)
```

### 2. Verify Configuration Contracts

```bash
# Validate docker-compose structure
docker-compose config

# Check environment variables
grep -E "^[A-Z_]+=" .env

# Verify image build capability
docker build -t graphiti-mcp-local .
```

### 3. Test Service Startup

```bash
# Start services in foreground for testing
docker-compose up --build

# In another terminal, verify services are healthy
curl -f http://localhost:7474  # Neo4j health
curl -f http://localhost:8000/health  # MCP server health

# Test MCP client connection (if available)
# Stop services for LaunchAgent setup
docker-compose down
```

### 4. Configure LaunchAgent Auto-startup

```bash
# Create startup script
cat > start_graphiti.sh << 'EOF'
#!/bin/bash
cd "$(dirname "$0")"

# Wait for Docker daemon
while ! docker info > /dev/null 2>&1; do
    sleep 2
done

# Start services
docker-compose up -d || {
    osascript -e 'display notification "Graphiti startup failed" with title "Docker MCP"'
    exit 1
}
EOF

chmod +x start_graphiti.sh

# Update LaunchAgent configuration
# (Implementation will modify plist file with correct paths)

# Load LaunchAgent
launchctl unload ~/Library/LaunchAgents/com.jiehoonk.graphiti-mcp.plist 2>/dev/null
launchctl load ~/Library/LaunchAgents/com.jiehoonk.graphiti-mcp.plist
```

## Validation Tests

### Service Health Verification

```bash
# Check LaunchAgent status
launchctl list | grep graphiti-mcp

# Verify Docker containers are running
docker ps

# Test database connectivity
docker exec -it $(docker ps -q -f name=neo4j) cypher-shell -u neo4j -p demodemo "RETURN 1"

# Test MCP server functionality
curl -X GET http://localhost:8000/status
```

### Data Continuity Verification

```bash
# Check existing graph data is accessible
# (This requires MCP client or direct database query)

# Verify group_id consistency
grep GROUP_ID .env

# Check volume data integrity
docker exec -it $(docker ps -q -f name=neo4j) ls -la /data
```

### Auto-startup Testing

```bash
# Simulate system restart behavior
docker-compose down
launchctl unload ~/Library/LaunchAgents/com.jiehoonk.graphiti-mcp.plist
launchctl load ~/Library/LaunchAgents/com.jiehoonk.graphiti-mcp.plist

# Wait for startup and verify services
sleep 30
docker ps | grep -E "(neo4j|graphiti)"
```

## Troubleshooting Guide

### Common Issues and Solutions

**Docker daemon not ready:**
```bash
# Check Docker Desktop is running
open -a "Docker Desktop"
# Wait for daemon to start, then retry
```

**Port conflicts:**
```bash
# Check for port usage
lsof -i :7474 -i :7687 -i :8000
# Kill conflicting processes or update port mappings
```

**Volume permission issues:**
```bash
# Check volume ownership
docker exec -it $(docker ps -q -f name=neo4j) ls -la /data
# Reset permissions if needed
docker-compose down
docker volume rm neo4j_data neo4j_logs  # Only if data recovery not critical
```

**LaunchAgent failures:**
```bash
# Check logs
tail -f /tmp/graphiti-mcp.log
tail -f /tmp/graphiti-mcp.error.log

# Verify script permissions
ls -la start_graphiti.sh
chmod +x start_graphiti.sh  # If needed
```

## Rollback Procedure

If migration fails, restore previous state:

```bash
# Stop new services
docker-compose down

# Restore configuration files
cp .env.backup.* .env
cp docker-compose.yml.backup docker-compose.yml
cp /tmp/launchagent.backup.plist ~/Library/LaunchAgents/com.jiehoonk.graphiti-mcp.plist

# Restart with previous configuration
launchctl unload ~/Library/LaunchAgents/com.jiehoonk.graphiti-mcp.plist
launchctl load ~/Library/LaunchAgents/com.jiehoonk.graphiti-mcp.plist
```

## Success Criteria

Migration is successful when:

- [ ] Docker containers start automatically on system boot
- [ ] Neo4j database contains existing graph data
- [ ] MCP server responds on port 8000
- [ ] MCP client can connect and query data
- [ ] LaunchAgent shows active status
- [ ] No errors in system logs
- [ ] GROUP_ID matches previous configuration
- [ ] Model fallback works for GPT compatibility
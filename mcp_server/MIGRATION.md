# Docker MCP Server Migration Guide

## Overview

This document provides troubleshooting guidance for migrating from Graphiti v0.14 to v0.30.0pre0 using the Docker-based MCP server setup.

## Migration Summary

- **From**: Graphiti v0.14 with GPT-5 compatibility
- **To**: Graphiti v0.30.0pre0 with GPT-4.1 model fallback
- **Approach**: Configuration-only changes (no Python source modifications)
- **Benefits**: Latest Graphiti features, improved stability, auto-startup capability

## Prerequisites

Before starting the migration, ensure you have:
- Docker Desktop running
- Docker Compose available
- `uv` package manager installed
- Existing Neo4j data volumes (automatically preserved)
- Valid OpenAI API key

## Configuration Changes

### 1. Docker Compose Updates
- **Neo4j**: Upgraded to version 5.26.0 with health checks
- **Graphiti MCP**: Uses local build instead of Docker Hub image
- **Version**: Removed obsolete version field from docker-compose.yml
- **Dependencies**: Graphiti service waits for healthy Neo4j

### 2. Environment Variables (.env)
- **Model Configuration**: Uses GPT-4.1 models instead of GPT-5
- **GROUP_ID**: Preserved as "default" for data continuity
- **Compatibility Note**: GPT-5 models avoided due to temperature parameter issue #878

### 3. Python Dependencies (pyproject.toml)
- **Graphiti Core**: Updated to exactly version 0.30.0pre0
- **Dependencies**: Cleaned up duplicates, maintained compatibility

### 4. LaunchAgent Configuration
- **Script Path**: Points to new `start_graphiti.sh` location
- **Working Directory**: Updated to current project path
- **Docker Polling**: Implements 2-second interval Docker daemon checks

## Troubleshooting Guide

### Docker Build Issues

**Problem**: Build fails with dependency resolution errors
```bash
# Solution: Clear Docker build cache
docker system prune -f
docker build --no-cache -t graphiti-mcp-local .
```

**Problem**: Old Graphiti version (0.14.0) installed in container
```bash
# Solution: Ensure pyproject.toml has exact version pin
echo 'graphiti-core==0.30.0pre0' # Should be exact match
uv sync  # Update lockfile
docker build --no-cache -t graphiti-mcp-local .
```

### Service Startup Issues

**Problem**: Neo4j service fails to start
```bash
# Check Neo4j logs
docker-compose logs neo4j

# Common fixes:
# 1. Check port availability
lsof -i :7474 -i :7687

# 2. Verify memory settings in docker-compose.yml
# 3. Check Neo4j data volume permissions
docker volume inspect mcp_server_neo4j_data
```

**Problem**: Graphiti MCP service exits immediately
```bash
# Check MCP server logs
docker-compose logs graphiti-mcp

# Common fixes:
# 1. Verify .env file exists and is properly formatted
# 2. Check OpenAI API key validity
# 3. Ensure Neo4j is healthy before MCP service starts
```

### LaunchAgent Issues

**Problem**: LaunchAgent fails to load
```bash
# Check LaunchAgent status
launchctl list | grep graphiti-mcp

# View LaunchAgent logs
tail -f ~/Library/Logs/graphiti-mcp.log

# Common fixes:
# 1. Verify plist file syntax
plutil ~/Library/LaunchAgents/com.jiehoonk.graphiti-mcp.plist

# 2. Check script permissions
ls -la start_graphiti.sh  # Should be executable

# 3. Ensure Docker daemon is available
docker info
```

**Problem**: Services don't auto-start on system boot
```bash
# Reload LaunchAgent
launchctl unload ~/Library/LaunchAgents/com.jiehoonk.graphiti-mcp.plist
launchctl load -w ~/Library/LaunchAgents/com.jiehoonk.graphiti-mcp.plist

# Check if already loaded
launchctl list | grep com.jiehoonk.graphiti-mcp
```

### Data Continuity Issues

**Problem**: Previous graph data not accessible
```bash
# Verify Neo4j volumes are preserved
docker volume ls | grep neo4j

# Check Neo4j connection with same credentials
NEO4J_URI=bolt://localhost:7687
NEO4J_USER=neo4j
NEO4J_PASSWORD=demodemo

# Ensure GROUP_ID remained "default" in .env
grep GROUP_ID .env  # Should show: GROUP_ID=default
```

### Model Compatibility Issues

**Problem**: GPT-5 model errors in logs
```bash
# Check .env for correct model configuration
grep -E "MODEL_NAME|SMALL_MODEL_NAME" .env

# Should show:
# MODEL_NAME=gpt-4.1-mini
# SMALL_MODEL_NAME=gpt-4.1-nano

# NOT gpt-5* variants due to issue #878
```

### Network and Port Issues

**Problem**: Services unreachable on localhost
```bash
# Check Docker port mappings
docker-compose ps

# Should show:
# - Neo4j: 0.0.0.0:7474->7474/tcp, 0.0.0.0:7687->7687/tcp
# - MCP: 0.0.0.0:8000->8000/tcp

# Test connectivity
curl -I http://localhost:7474  # Should return 200 OK
curl -I http://localhost:8000  # Should return 404 (normal for MCP)
```

## Health Check Commands

Use these commands to verify system health:

```bash
# 1. Docker Compose syntax
docker-compose config

# 2. Service status
docker-compose ps

# 3. Service logs
docker-compose logs -f

# 4. Health endpoints
./healthcheck.sh

# 5. LaunchAgent status
launchctl list | grep graphiti-mcp
```

## Rollback Procedure

If migration encounters critical issues, use these backup files:

```bash
# Stop current services
docker-compose down

# Restore backup files
cp .env.backup.20250926_133643 .env
cp docker-compose.yml.backup.20250926_133649 docker-compose.yml
cp launchagent.backup.20250926_133656.plist ~/Library/LaunchAgents/com.jiehoonk.graphiti-mcp.plist

# Restart with previous configuration
docker-compose up -d
```

## Performance Optimization

### Memory Settings (Neo4j)
```yaml
# In docker-compose.yml, adjust based on available RAM:
environment:
  - NEO4J_server_memory_heap_initial__size=512m  # Start smaller for limited RAM
  - NEO4J_server_memory_heap_max__size=1G        # Increase for better performance
  - NEO4J_server_memory_pagecache_size=512m      # Balance with heap size
```

### Docker Resource Limits
```yaml
# Optional: Add resource limits to docker-compose.yml
deploy:
  resources:
    limits:
      memory: 2G
      cpus: '1.0'
```

## Support Information

- **Graphiti Version**: 0.30.0pre0
- **Neo4j Version**: 5.26.0
- **Docker Compose Version**: 3.8+ (version field obsolete)
- **Python Version**: 3.10+
- **Package Manager**: uv

For additional support, check:
- Graphiti documentation and GitHub issues
- Neo4j connection troubleshooting guides
- Docker Compose networking documentation
- macOS LaunchAgent troubleshooting guides

## Migration Validation

After migration, verify these items:

- [ ] Neo4j accessible at http://localhost:7474
- [ ] MCP server responding at http://localhost:8000
- [ ] Graphiti version 0.30.0pre0 in container logs
- [ ] Previous graph data accessible with GROUP_ID=default
- [ ] LaunchAgent configured for auto-startup
- [ ] GPT-4.1 models working correctly
- [ ] Docker daemon polling working in startup script

## Common Error Messages

**"graphiti-core 0.14.0 installed instead of 0.30.0pre0"**
- Clear Docker build cache and rebuild
- Verify pyproject.toml has exact version pin

**"Neo4j authentication failed"**
- Check NEO4J_AUTH environment variable format
- Verify credentials match .env file

**"LaunchAgent failed to start"**
- Check Docker daemon availability
- Verify script permissions and paths

**"Temperature parameter not supported"**
- Indicates GPT-5 model usage - switch to GPT-4.1 models in .env
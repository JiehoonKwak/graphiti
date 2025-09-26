# Research Findings: Docker MCP Server Migration

## Neo4j Version Compatibility

**Decision**: Use Neo4j 5.26.0 (same as current setup) with explicit version compatibility checks

**Rationale**:
- Graphiti 0.30.0pre0 supports Neo4j 5.26+ (confirmed in pyproject.toml dependencies)
- Existing data volumes use Neo4j 5.26.0 format - same version eliminates migration risk
- Docker health checks can verify schema compatibility before startup

**Alternatives Considered**:
- Upgrade to Neo4j 5.28+ (latest): Risk of data format incompatibility
- Downgrade approach: Would lose performance/security improvements

## Docker Image Strategy

**Decision**: Build local Docker image from current repository instead of using Docker Hub

**Rationale**:
- Docker Hub images lag behind (currently 0.14 vs needed 0.30.0pre0)
- Local build ensures latest Graphiti version with all recent improvements
- Dockerfile already exists and supports uv package management
- Build context uses current repository state automatically

**Alternatives Considered**:
- Wait for Docker Hub update: Timeline uncertain, blocks upgrade path
- Custom registry: Unnecessary complexity for single-user setup

## LaunchAgent Integration

**Decision**: Create start_graphiti.sh script with Docker daemon polling and error handling

**Rationale**:
- LaunchAgent requires executable script for ProgramArguments
- Docker daemon polling (2-second intervals) more efficient than fixed timeouts
- Error alerting via system notifications while continuing restart attempts
- Working directory control ensures proper path resolution

**Alternatives Considered**:
- Direct docker-compose in LaunchAgent: No daemon readiness checking
- System service approach: LaunchAgent more appropriate for user-level services

**Implementation Pattern**:
```bash
# Poll for Docker daemon readiness
while ! docker info > /dev/null 2>&1; do
    sleep 2
done

# Start services with error handling
docker-compose up -d || {
    osascript -e 'display notification "Docker startup failed" with title "Graphiti MCP"'
    exit 1
}
```

## GPT-5 Model Fallback

**Decision**: Use environment variable cascade for model selection without source code changes

**Rationale**:
- Issue #878 shows GPT-5 requires different parameters (no temperature, uses reasoning_effort)
- Current codebase can handle model fallback through MODEL_NAME environment variable
- No source modification needed - just environment configuration
- Fallback chain: gpt-5 → gpt-4.1-mini → gpt-4.1-nano

**Alternatives Considered**:
- Patch OpenAI client code: Violates constitution (no source changes)
- Custom model wrapper: Adds unnecessary complexity

**Environment Configuration**:
```env
# Primary model (with known GPT-5 compatibility issue)
MODEL_NAME=gpt-4.1-mini
SMALL_MODEL_NAME=gpt-4.1-nano

# Fallback strategy documented in comments
# GPT-5 currently unsupported due to parameter incompatibility
# See: https://github.com/getzep/graphiti/issues/878
```

## Volume Migration Safety

**Decision**: Preserve existing volume names and mount paths, add pre-startup compatibility check

**Rationale**:
- Same Neo4j version (5.26.0) ensures data format compatibility
- Existing volumes (neo4j_data, neo4j_logs) contain valuable graph data
- Health checks can verify data integrity before service startup
- Fail-fast approach prevents data corruption

**Alternatives Considered**:
- Backup and restore: Complex and unnecessary for same-version migration
- New volume creation: Loss of existing data

**Safety Implementation**:
- Docker health checks verify Neo4j connectivity
- Volume mounts preserve exact paths: `/data` and `/logs`
- Startup script includes compatibility verification step

## Dependency Management Strategy

**Decision**: Pin exact versions in pyproject.toml, use uv.lock for reproducible builds

**Rationale**:
- uv provides fast, deterministic dependency resolution
- Lock file ensures consistent builds across environments
- Exact version pinning prevents unexpected updates during critical migration

**Version Specifications**:
```toml
[project]
dependencies = [
    "graphiti-core==0.30.0pre0",
    # Other dependencies managed by graphiti-core
]
```

## Health Check Implementation

**Decision**: Multi-layered health checks for both Neo4j and Graphiti MCP server

**Rationale**:
- Neo4j health check prevents Graphiti startup with unhealthy database
- MCP server health check validates end-to-end functionality
- LaunchAgent can use health status for restart decisions

**Health Check Stack**:
1. Neo4j HTTP endpoint: `curl -f http://localhost:7474`
2. Neo4j Bolt connectivity: Connection test in health script
3. MCP server responsiveness: Port 8000 availability check

## Configuration Migration Path

**Decision**: Update existing mcp_server/.env and docker-compose.yml incrementally

**Rationale**:
- Preserves working configuration as base
- Incremental changes reduce risk of complete failure
- Existing environment variables maintained for compatibility

**Migration Steps**:
1. Update docker-compose.yml: Change image build strategy, version pins
2. Update .env: Add model fallback documentation, preserve existing values
3. Update Dockerfile: Ensure uv sync uses latest dependencies
4. Add startup scripts: LaunchAgent integration, health checks
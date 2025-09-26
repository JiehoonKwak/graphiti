# Data Model: Docker MCP Server Migration

## Configuration Entities

### DockerComposeService
**Purpose**: Represents each service in docker-compose.yml configuration

**Attributes**:
- `name`: Service identifier (e.g., "neo4j", "graphiti-mcp")
- `image`: Docker image specification with version
- `ports`: Port mapping array (host:container)
- `environment`: Environment variable dictionary
- `volumes`: Volume mount specifications
- `depends_on`: Service dependency configuration
- `health_check`: Health check command and parameters

**Validation Rules**:
- Neo4j service MUST use version 5.26.0 for compatibility
- Graphiti MCP service MUST build from current repository context
- Port mappings MUST not conflict with system services
- Health checks MUST be defined for both services

### EnvironmentConfiguration
**Purpose**: Manages .env file variables and their validation

**Attributes**:
- `neo4j_uri`: Database connection string
- `neo4j_user`: Database username
- `neo4j_password`: Database password
- `openai_api_key`: API key for LLM operations
- `model_name`: Primary LLM model identifier
- `small_model_name`: Fallback model for smaller operations
- `group_id`: Graphiti namespace identifier (default: "default")

**Validation Rules**:
- API key MUST be present and valid format
- Model names MUST be supported by current Graphiti version
- Group ID MUST match existing data for continuity
- Connection strings MUST use correct protocol and port

### LaunchAgentConfiguration
**Purpose**: Defines macOS LaunchAgent plist structure

**Attributes**:
- `label`: Unique service identifier
- `program_arguments`: Executable script path array
- `working_directory`: Execution context directory
- `run_at_load`: Auto-start on system boot
- `keep_alive`: Restart on failure
- `environment_variables`: PATH and other required variables

**State Transitions**:
1. `Inactive` → `Loading` (system boot)
2. `Loading` → `WaitingForDocker` (daemon polling)
3. `WaitingForDocker` → `Starting` (daemon ready)
4. `Starting` → `Running` (services healthy)
5. `Running` → `Failed` (service failure)
6. `Failed` → `Loading` (restart attempt)

### DockerVolume
**Purpose**: Persistent data storage configuration

**Attributes**:
- `name`: Volume identifier (neo4j_data, neo4j_logs)
- `mount_path`: Container mount point
- `driver`: Storage driver (local)
- `driver_opts`: Driver-specific options

**Relationships**:
- Each `DockerComposeService` can mount multiple `DockerVolume` instances
- `DockerVolume` instances persist across service restarts and updates

## Configuration Schema Relationships

```
DockerComposeService "neo4j"
├── mounts DockerVolume "neo4j_data" at /data
├── mounts DockerVolume "neo4j_logs" at /logs
└── uses EnvironmentConfiguration for auth

DockerComposeService "graphiti-mcp"
├── depends_on DockerComposeService "neo4j"
├── uses EnvironmentConfiguration for all settings
└── exposes port 8000 for MCP clients

LaunchAgentConfiguration
└── executes StartupScript with DockerComposeService management

EnvironmentConfiguration
├── provides connection details to both services
└── manages model fallback strategy for GPT compatibility
```

## Validation Dependencies

### Cross-Entity Validation
1. **Version Compatibility**: Neo4j service version MUST be compatible with Graphiti dependencies
2. **Port Conflicts**: Service ports MUST not overlap with system or user services
3. **Volume Consistency**: Mount paths MUST match Neo4j expectations
4. **Environment Completeness**: Required variables MUST be present for service startup

### Migration Safety Checks
1. **Data Preservation**: Existing volume data MUST be compatible with new service versions
2. **Configuration Rollback**: Previous configuration MUST be preserved for rollback capability
3. **Startup Dependencies**: Service startup order MUST ensure database readiness before MCP server

## Configuration File Mapping

### docker-compose.yml Structure
```yaml
services:
  neo4j: DockerComposeService
  graphiti-mcp: DockerComposeService
volumes:
  neo4j_data: DockerVolume
  neo4j_logs: DockerVolume
```

### .env Structure
```env
# Maps to EnvironmentConfiguration attributes
NEO4J_URI=...
NEO4J_USER=...
OPENAI_API_KEY=...
MODEL_NAME=...
# etc.
```

### LaunchAgent plist Structure
```xml
<dict>
  <!-- Maps to LaunchAgentConfiguration attributes -->
  <key>Label</key>
  <key>ProgramArguments</key>
  <key>WorkingDirectory</key>
  <!-- etc. -->
</dict>
```
# Implementation Plan: Docker MCP Server Migration with Latest Graphiti

**Branch**: `001-i-want-to` | **Date**: 2025-01-26 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/Users/jiehoonk/DevHub/sideprojects/graphiti/specs/001-i-want-to/spec.md`

## Execution Flow (/plan command scope)
```
1. Load feature spec from Input path
   → ✅ LOADED spec.md with clarifications
2. Fill Technical Context (scan for NEEDS CLARIFICATION)
   → ✅ COMPLETED - Docker/Python project type detected
3. Fill the Constitution Check section based on the content of the constitution document.
   → ✅ COMPLETED - All constitutional principles addressed
4. Evaluate Constitution Check section below
   → ✅ PASSED - No violations, all changes configuration-only
5. Execute Phase 0 → research.md
   → ✅ COMPLETED research.md with all technical decisions
6. Execute Phase 1 → contracts, data-model.md, quickstart.md, CLAUDE.md
   → ✅ COMPLETED all design artifacts
7. Re-evaluate Constitution Check section
   → ✅ VERIFIED - All constitutional requirements maintained
8. Plan Phase 2 → Describe task generation approach (DO NOT create tasks.md)
   → ✅ COMPLETED task strategy defined
9. STOP - Ready for /tasks command
```

**IMPORTANT**: The /plan command STOPS at step 8. Phase 2 is executed by /tasks command.

## Summary
Migrate Docker MCP server configuration from Graphiti v0.14 to v0.30.0pre0 while preserving existing Neo4j data, maintaining group_id consistency, and enabling auto-startup via macOS LaunchAgent. The solution uses configuration-only changes (docker-compose.yml, Dockerfile, .env) without modifying Python source code, ensuring compatibility with main repository updates.

## Technical Context
**Language/Version**: Python 3.10+ (required by Graphiti), uv package manager, Docker & Docker Compose
**Primary Dependencies**: graphiti-core 0.30.0pre0, Neo4j 5.26+, OpenAI API, uv sync
**Storage**: Neo4j graph database with persistent Docker volumes (neo4j_data, neo4j_logs)
**Testing**: Docker Compose startup verification, MCP client connection testing, version compatibility checks
**Target Platform**: macOS (Docker Desktop), LaunchAgent integration for auto-startup
**Project Type**: Container-based configuration (docker-compose multi-service)
**Performance Goals**: <30s startup time, 2s Docker daemon polling interval, container health checks
**Constraints**: Configuration-only changes, no Python source modifications, preserve existing data/settings
**Scale/Scope**: Single developer setup, 2 containers (Neo4j + Graphiti MCP), local development environment

**User Implementation Context**: Don't modify source code (.py). Create configuration in mcp_server/ for main repository compatibility. Avoid unnecessary intermediate files. Pursue clean, robust, maintainable approach. Handle Python package management with uv, Dockerfile, docker-compose, .env dependencies.

## Constitution Check
*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

✅ **I. Configuration-Only Changes**: All modifications restricted to mcp_server/ config files (.env, docker-compose.yml, Dockerfile, pyproject.toml). No Python source code changes.

✅ **II. Latest Version Alignment**: Target Graphiti 0.30.0pre0, Neo4j 5.26+. All dependencies use current stable versions.

✅ **III. Minimal Change Principle**: Only essential configuration modifications. Prefer environment variables over structural changes.

✅ **IV. Environment-Based Configuration**: Runtime behavior controlled through .env, Docker environment variables, compose configuration.

✅ **V. Container Compatibility**: Maintain stdio/sse MCP transport compatibility, preserve existing Docker Compose workflows.

## Project Structure

### Documentation (this feature)
```
specs/001-i-want-to/
├── plan.md              # This file (/plan command output)
├── research.md          # Phase 0 output (/plan command)
├── data-model.md        # Phase 1 output (/plan command)
├── quickstart.md        # Phase 1 output (/plan command)
├── contracts/           # Phase 1 output (/plan command)
└── tasks.md             # Phase 2 output (/tasks command - NOT created by /plan)
```

### Source Code (repository root)
```
mcp_server/
├── docker-compose.yml   # Multi-service orchestration with latest versions
├── Dockerfile           # Local build for current Graphiti version
├── .env                 # Environment configuration with model fallbacks
├── .env.example         # Template for required variables
├── pyproject.toml       # uv dependency management
├── uv.lock              # Locked dependencies
├── graphiti_mcp_server.py  # Unchanged source code
├── start_graphiti.sh    # LaunchAgent startup script
└── healthcheck.sh       # Docker health check script
```

**Structure Decision**: Configuration-focused approach using existing mcp_server/ directory. All changes target configuration files only, preserving source code integrity for upstream compatibility.

## Phase 0: Outline & Research

**Research Tasks Identified**:
1. **Neo4j Version Compatibility**: Research Neo4j 5.26+ compatibility with Graphiti 0.30.0pre0 data migration paths
2. **Docker Image Strategy**: Determine optimal approach for local builds vs. Docker Hub images for latest versions
3. **LaunchAgent Integration**: Research macOS LaunchAgent patterns for Docker service management and daemon dependencies
4. **GPT-5 Model Fallback**: Investigate environment-based model configuration for GPT-5 compatibility without source changes
5. **Volume Migration Safety**: Research Docker volume preservation strategies during version upgrades

## Phase 1: Design & Contracts
*Prerequisites: research.md complete*

✅ **Generated Design Artifacts**:
- **data-model.md**: Configuration entities (DockerComposeService, EnvironmentConfiguration, LaunchAgentConfiguration, DockerVolume)
- **contracts/**: Validation schemas for docker-compose.yml, .env, and LaunchAgent plist
- **quickstart.md**: Step-by-step migration guide with validation tests and rollback procedures
- **CLAUDE.md**: Updated agent context with latest technical stack information

## Phase 2: Task Planning Approach
*This section describes what the /tasks command will do - DO NOT execute during /plan*

**Task Generation Strategy**:
- Load `.specify/templates/tasks-template.md` as base
- Generate configuration validation tasks from contracts/ directory
- Each configuration file → validation task [P]
- Each environment variable → verification task [P]
- LaunchAgent integration → startup test task
- Docker services → health check tasks
- Migration safety → rollback capability task

**Ordering Strategy**:
- Configuration-first: .env, docker-compose.yml, Dockerfile updates
- Validation order: Syntax validation → semantic validation → integration testing
- Dependency order: Docker build → service startup → health verification → LaunchAgent
- Mark [P] for parallel execution (independent configuration files)

**Configuration Task Categories**:
1. **Pre-Migration**: Backup existing configuration, validate prerequisites
2. **Core Configuration**: Update docker-compose.yml, .env, Dockerfile per contracts
3. **Startup Scripts**: Create start_graphiti.sh with Docker daemon polling
4. **LaunchAgent Setup**: Update plist configuration, test auto-startup
5. **Validation Testing**: Verify service health, data continuity, client connectivity
6. **Documentation**: Update README with migration notes and troubleshooting

**Estimated Output**: 18-22 numbered, ordered tasks focusing on configuration changes only

**IMPORTANT**: This phase is executed by the /tasks command, NOT by /plan

## Phase 3+: Future Implementation
*These phases are beyond the scope of the /plan command*

**Phase 3**: Task execution (/tasks command creates tasks.md)
**Phase 4**: Configuration implementation (execute tasks.md following constitutional principles)
**Phase 5**: Validation (run health checks, test auto-startup, verify data continuity)

## Complexity Tracking
*No constitutional violations identified - all changes are configuration-only*

No complexity deviations required. All implementation follows constitutional principles:
- Configuration-only changes within mcp_server/ directory
- Latest version alignment with Graphiti 0.30.0pre0
- Minimal change principle with environment-based configuration
- Container compatibility maintained for stdio/sse transports

## Progress Tracking

**Phase Status**:
- [x] Phase 0: Research complete (/plan command)
- [x] Phase 1: Design complete (/plan command)
- [x] Phase 2: Task planning complete (/plan command - describe approach only)
- [ ] Phase 3: Tasks generated (/tasks command)
- [ ] Phase 4: Implementation complete
- [ ] Phase 5: Validation passed

**Gate Status**:
- [x] Initial Constitution Check: PASS
- [x] Post-Design Constitution Check: PASS
- [x] All NEEDS CLARIFICATION resolved
- [x] Complexity deviations documented (none required)

---
*Based on Constitution v1.0.0 - See `.specify/memory/constitution.md`*
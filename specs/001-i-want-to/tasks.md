# Tasks: Docker MCP Server Migration with Latest Graphiti

**Input**: Design documents from `/Users/jiehoonk/DevHub/sideprojects/graphiti/specs/001-i-want-to/`
**Prerequisites**: plan.md, research.md, data-model.md, contracts/, quickstart.md

## Execution Flow (main)
```
1. Load plan.md from feature directory
   → ✅ LOADED: Docker/Python project, configuration-only approach
   → Extract: uv package manager, Docker Compose, Neo4j 5.26+, Graphiti 0.30.0pre0
2. Load optional design documents:
   → data-model.md: DockerComposeService, EnvironmentConfiguration, LaunchAgentConfiguration
   → contracts/: docker-compose validation, environment schema, LaunchAgent plist
   → research.md: Local build strategy, volume safety, GPT-5 fallback decisions
3. Generate tasks by category:
   → Setup: backups, prerequisite verification
   → Tests: configuration validation, health checks
   → Core: docker-compose.yml, .env, Dockerfile updates
   → Integration: LaunchAgent, startup scripts
   → Polish: testing, documentation, rollback capability
4. Apply task rules:
   → Different config files = mark [P] for parallel
   → Same file edits = sequential (no [P])
   → Validation before configuration changes
5. Number tasks sequentially (T001, T002...)
6. ✅ SUCCESS (tasks ready for configuration migration)
```

## Format: `[ID] [P?] Description`
- **[P]**: Can run in parallel (different files, no dependencies)
- Include exact file paths in descriptions

## Path Conventions
- **Configuration root**: `mcp_server/` directory
- **Backup location**: Current directory with timestamp suffixes
- **LaunchAgent**: `~/Library/LaunchAgents/com.jiehoonk.graphiti-mcp.plist`
- All paths assume mcp_server/ as working directory

## Phase 3.1: Setup & Prerequisites
- [x] T001 Verify prerequisites (Docker, uv, existing configs) per quickstart.md
- [x] T002 [P] Create backup of existing `.env` file with timestamp
- [x] T003 [P] Create backup of existing `docker-compose.yml` file
- [x] T004 [P] Create backup of LaunchAgent plist `/Users/jiehoonk/Library/LaunchAgents/com.jiehoonk.graphiti-mcp.plist`
- [x] T005 Stop existing Docker services with `docker-compose down`

## Phase 3.2: Configuration Validation Tests (TDD) ⚠️ MUST COMPLETE BEFORE 3.3
**CRITICAL: These validation tests MUST be written and MUST FAIL before configuration changes**
- [x] T006 [P] Contract validation test for docker-compose.yml in `validate_compose.py`
- [x] T007 [P] Contract validation test for .env variables in `validate_env.py`
- [x] T008 [P] Contract validation test for LaunchAgent plist in `validate_plist.py`
- [x] T009 [P] Integration test for Docker build process in `test_docker_build.py`
- [x] T010 [P] Integration test for service health checks in `test_service_health.py`

## Phase 3.3: Core Configuration Updates (ONLY after validation tests fail)
- [x] T011 Update `docker-compose.yml` - Neo4j service with version 5.26.0 and health check
- [x] T012 Update `docker-compose.yml` - Graphiti MCP service with local build and dependencies
- [x] T013 Update `docker-compose.yml` - Volume configurations preserving neo4j_data and neo4j_logs
- [x] T014 Update `.env` - Model configuration with GPT-5 fallback documentation
- [x] T015 Update `.env` - Preserve GROUP_ID=default and existing database credentials
- [x] T016 Update `Dockerfile` - Ensure uv sync uses graphiti-core 0.30.0pre0
- [x] T017 [P] Create `start_graphiti.sh` startup script with Docker daemon polling
- [x] T018 [P] Create `healthcheck.sh` script for service health validation

## Phase 3.4: LaunchAgent Integration
- [x] T019 Update LaunchAgent plist with correct `start_graphiti.sh` path
- [x] T020 Set executable permissions on `start_graphiti.sh` (chmod +x)
- [x] T021 Update LaunchAgent WorkingDirectory to current mcp_server path
- [x] T022 Test Docker daemon polling logic in startup script

## Phase 3.5: Validation & Testing
- [x] T023 [P] Validate docker-compose.yml syntax with `docker-compose config`
- [x] T024 [P] Validate .env variables match contract requirements
- [x] T025 Test Docker image build process with `docker build -t graphiti-mcp-local .`
- [x] T026 Test service startup with `docker-compose up --build`
- [x] T027 Verify Neo4j health endpoint http://localhost:7474
- [x] T028 Verify MCP server health endpoint http://localhost:8000
- [x] T029 Test LaunchAgent loading with `launchctl load`
- [x] T030 Test auto-startup behavior after LaunchAgent configuration

## Phase 3.6: Polish & Documentation
- [x] T031 [P] Create migration troubleshooting guide in `MIGRATION.md`
- [x] T032 [P] Update README.md with new version information and startup instructions
- [x] T033 Verify existing Neo4j data volumes are accessible and GROUP_ID consistency
- [x] T034 Test rollback procedure using backup files
- [x] T035 Document GPT-5 compatibility issue and model fallback in comments

## Dependencies
- Prerequisites (T001-T005) before validation tests (T006-T010)
- Validation tests (T006-T010) before configuration updates (T011-T018)
- T011-T013 (docker-compose.yml) before T025-T026 (Docker testing)
- T014-T015 (.env) before T027-T028 (service health)
- T017-T018 (scripts) before T019-T022 (LaunchAgent)
- T019-T022 (LaunchAgent) before T029-T030 (auto-startup testing)
- Core implementation before polish (T031-T035)

## Parallel Example
```
# Launch backup tasks together (T002-T004):
Task: "Create backup of existing .env file with timestamp"
Task: "Create backup of existing docker-compose.yml file"
Task: "Create backup of LaunchAgent plist"

# Launch validation tests together (T006-T010):
Task: "Contract validation test for docker-compose.yml in validate_compose.py"
Task: "Contract validation test for .env variables in validate_env.py"
Task: "Contract validation test for LaunchAgent plist in validate_plist.py"
Task: "Integration test for Docker build process in test_docker_build.py"
Task: "Integration test for service health checks in test_service_health.py"

# Launch final validation together (T023-T024):
Task: "Validate docker-compose.yml syntax with docker-compose config"
Task: "Validate .env variables match contract requirements"
```

## Configuration File Targets

### docker-compose.yml Updates
- Neo4j service: version 5.26.0, health check, memory settings
- Graphiti MCP service: local build context, environment variables, port 8000
- Volumes: preserve neo4j_data and neo4j_logs mounts
- Dependencies: graphiti-mcp depends on healthy neo4j service

### .env Updates
- MODEL_NAME: gpt-4.1-mini (GPT-5 compatibility fallback)
- SMALL_MODEL_NAME: gpt-4.1-nano
- GROUP_ID: preserve "default" value for data continuity
- Add documentation comments for GPT-5 issue #878

### LaunchAgent Configuration
- ProgramArguments: point to new start_graphiti.sh script
- WorkingDirectory: absolute path to mcp_server directory
- Environment PATH: include Docker and system tools
- KeepAlive: true for restart on failure

## Validation Checklist
*GATE: Checked before task completion*

- [x] All contracts have corresponding validation tests (T006-T010)
- [x] All configuration entities have update tasks (docker-compose, .env, scripts)
- [x] All validation tests come before configuration changes
- [x] Parallel tasks truly independent (different files)
- [x] Each task specifies exact file path or command
- [x] No task modifies same file as another [P] task
- [x] Constitutional compliance: configuration-only changes, no .py modifications

## Notes
- [P] tasks = different files, no dependencies
- Verify validation tests fail before updating configurations
- Preserve existing data and settings during migration
- Use GPT-4.1 models due to GPT-5 compatibility issue
- All changes follow constitutional principle: configuration-only
- Working directory: `/Users/jiehoonk/DevHub/sideprojects/graphiti/mcp_server`
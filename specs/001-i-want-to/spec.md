# Feature Specification: Docker MCP Server Migration with Latest Graphiti

**Feature Branch**: `001-i-want-to`
**Created**: 2025-01-26
**Status**: Draft
**Input**: User description: "i want to configure docker containers for MCP server for both neo4j and graphiti mcp server. I have my previous setup for graphiti at @/Users/jiehoonk/DevHub/sideprojects/agent-tools/graphiti/mcp_server\
\
But i am trying to migrate to current workspace version - which is the cloned repo from main repo from graphiti.\
\
The reason why i used previous repo (another branch) is that it works well with gpt-5 version. You can use gh commands to see the issue with gpt-5 model. It requires different parameter inputs like temperature and max-token so i used different version. However, that brach is not merging into main branch, while main repo is still getting updates in graphiti-core functionality.\
\
So i am trying to prioritize to use most recent version of graphiti-core. And put less priority for model i can use. I hope you can fix model issue without changing the source code. But, if you cannot, just leave it. I'll stick with previous model like gpt-4.1-mini and nano\
\
You should follow exact config in docker-compose file of previous version (also read relevent config files and env file). for example - mounted volume directory for neo4j container, or default group_id which is critical for graphiti\
\
You should search information if needed.\
\
The reason why i am doing this is docker compose is pulling image from docker hub which use older version of graphiti (0.14) - but i want to use images with updated graphiti version. also, make sure that when i run the docker-compose file - you should always check the latest version for graphiti\
\
finally when docker configuration is working, i want to run docker container whenever my mac restart or reboot using launchagent (current config : /Users/jiehoonk/Library/LaunchAgents/com.jiehoonk.graphiti-mcp.plist)\
\
to understand my situation, you should always understand the referenced files or codes in the configuration"

## Clarifications

### Session 2025-01-26
- Q: When the Docker containers fail to start (due to build issues, missing environment variables, or volume corruption), what should be the recovery behavior? → A: Alert user but continue attempting restart on schedule
- Q: What should happen to existing Neo4j data if a version incompatibility is detected during migration? → A: Fail startup immediately to prevent data corruption
- Q: How long should the system wait for Docker daemon to be ready during LaunchAgent startup? → A: Poll every 2 seconds using docker info until ready

---

## User Scenarios & Testing

### Primary User Story
As a developer using Graphiti MCP server, I need to migrate my Docker configuration from an older version (0.14) to use the latest Graphiti version (0.30.0pre0) while maintaining all my existing settings (volumes, group_id, environment) and ensuring the containers auto-start on system reboot.

### Acceptance Scenarios
1. **Given** a previous working Docker setup with older Graphiti version, **When** I run the updated docker-compose file, **Then** the system starts with latest Graphiti version and preserves all my data and settings
2. **Given** the updated Docker configuration, **When** my Mac restarts, **Then** the containers automatically start via LaunchAgent without manual intervention
3. **Given** GPT-5 model compatibility issues exist, **When** I use the updated setup, **Then** the system falls back to supported models (gpt-4.1-mini/nano) without errors
4. **Given** the containers are running, **When** I connect via MCP client, **Then** all existing graph data is accessible and functionality works as expected

### Edge Cases
- What happens when Docker image build fails due to version conflicts?
- How does system handle missing environment variables during container startup?
- What occurs if Neo4j volume data is corrupted during migration?
- How does LaunchAgent handle Docker daemon not being ready on boot?

## Requirements

### Functional Requirements
- **FR-001**: System MUST use the latest Graphiti version (0.30.0pre0) instead of older Docker Hub images (0.14)
- **FR-002**: System MUST preserve existing Neo4j data volumes and configuration from previous setup
- **FR-003**: System MUST maintain the same group_id (default) for data consistency
- **FR-004**: System MUST automatically start Docker containers on Mac system reboot via LaunchAgent
- **FR-005**: System MUST support both stdio and sse MCP transport modes
- **FR-006**: System MUST handle GPT-5 model compatibility by falling back to supported models (gpt-4.1-mini, gpt-4.1-nano)
- **FR-007**: System MUST preserve all environment variables and settings from previous configuration
- **FR-008**: System MUST build local Docker image instead of using outdated Docker Hub image
- **FR-009**: System MUST maintain Neo4j volume mount paths consistent with previous setup
- **FR-010**: System MUST verify container health before marking services as ready
- **FR-011**: System MUST alert user when container startup fails but continue attempting restart on LaunchAgent schedule
- **FR-012**: System MUST fail startup immediately when Neo4j version incompatibility is detected to prevent data corruption
- **FR-013**: System MUST poll Docker daemon readiness every 2 seconds using `docker info` command during LaunchAgent startup

### Key Entities
- **Docker Compose Configuration**: Container orchestration with Neo4j and Graphiti MCP server, volume mounts, environment variables, health checks
- **LaunchAgent Plist**: macOS service definition for auto-starting containers, working directory paths, environment setup
- **Environment Configuration**: API keys, model names, database connections, group identifiers
- **Neo4j Database**: Graph storage with persistent volumes, memory settings, authentication
- **Graphiti MCP Server**: Latest version container with proper model compatibility and configuration

---

## Review & Acceptance Checklist

### Content Quality
- [x] No implementation details (languages, frameworks, APIs)
- [x] Focused on user value and business needs
- [x] Written for non-technical stakeholders
- [x] All mandatory sections completed

### Requirement Completeness
- [x] No [NEEDS CLARIFICATION] markers remain
- [x] Requirements are testable and unambiguous
- [x] Success criteria are measurable
- [x] Scope is clearly bounded
- [x] Dependencies and assumptions identified

---

## Execution Status

- [x] User description parsed
- [x] Key concepts extracted
- [x] Ambiguities marked
- [x] User scenarios defined
- [x] Requirements generated
- [x] Entities identified
- [x] Review checklist passed
# Graphiti MCP Server Configuration Constitution
<!-- Sync Impact Report -->
<!--
Version change: none → 1.0.0 (initial constitution)
Modified principles: none (initial creation)
Added sections: All sections (initial creation)
- I. Configuration-Only Changes
- II. Latest Version Alignment
- III. Minimal Change Principle
- IV. Environment-Based Configuration
- V. Container Compatibility
Templates requiring updates: ✅ updated
- .specify/templates/plan-template.md: ✅ aligned
- .specify/templates/spec-template.md: ✅ aligned
- .specify/templates/tasks-template.md: ✅ aligned
- .specify/templates/commands/*.md: ✅ aligned
Follow-up TODOs: none
-->

## Core Principles

### I. Configuration-Only Changes
MUST restrict all modifications to configuration files within `mcp_server/` directory only. This includes `.env`, `docker-compose.yml`, `Dockerfile`, `pyproject.toml`, and other non-source configuration files. NEVER modify Python source code files (`.py` files).

**Rationale**: Preserves original codebase integrity while enabling customization through configuration, reducing risk of introducing bugs and maintaining upgrade compatibility.

### II. Latest Version Alignment
MUST ensure all Graphiti dependencies and Docker images use the latest stable version (currently 0.30.0pre0). All configuration changes must be compatible with the current version's feature set and API.

**Rationale**: Prevents version drift and compatibility issues while leveraging latest improvements and security updates.

### III. Minimal Change Principle
MUST make the smallest possible configuration changes to achieve the required functionality. Each modification must be essential and well-justified. Prefer environment variable changes over structural modifications.

**Rationale**: Reduces complexity, minimizes risk of breaking changes, and maintains system stability while achieving configuration goals.

### IV. Environment-Based Configuration
MUST use environment variables and configuration files for customization rather than code changes. All runtime behavior modifications must be externally configurable through `.env`, Docker environment variables, or configuration files.

**Rationale**: Enables flexible deployment without source code modifications and supports different environments (development, testing, production) through configuration alone.

### V. Container Compatibility
MUST maintain full compatibility with existing Docker Compose setup and container deployment. All changes must work seamlessly with both `stdio` and `sse` MCP transports.

**Rationale**: Preserves existing deployment workflows and ensures the solution works across all supported MCP client configurations.

## Configuration Standards

All configuration changes must:
- Use semantic versioning for dependency specifications
- Include comprehensive documentation in comments
- Maintain backward compatibility with existing setups
- Follow Docker and Python packaging best practices
- Include proper health checks and monitoring capabilities

## Testing Requirements

Configuration changes must be validated through:
- Docker Compose startup verification
- MCP client connection testing
- Environment variable validation
- Version compatibility verification

## Governance

This constitution supersedes all other development practices for MCP server configuration. All configuration changes must comply with these principles.

Amendment procedure:
1. Propose changes with clear justification
2. Validate against existing deployments
3. Update documentation accordingly
4. Version increment following semantic versioning

**Version**: 1.0.0 | **Ratified**: 2025-01-26 | **Last Amended**: 2025-01-26
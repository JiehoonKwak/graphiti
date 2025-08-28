# Graphiti Project Context

## Project Overview
Graphiti is a framework for building temporally-aware knowledge graphs designed for AI agents. This is a forked repository with custom modifications to support Google Gemini as an LLM provider.

## Recent Changes (2025-08-28)

### Gemini LLM Integration
- **Objective**: Add Google Gemini support to MCP server as alternative to OpenAI
- **Approach**: Minimal, fork-friendly changes that maintain backward compatibility
- **Status**: ✅ Complete and tested

### Key Modifications Made

#### 1. MCP Server Core (`mcp_server/graphiti_mcp_server.py`)
- Added Gemini client imports with graceful error handling
- Extended configuration classes to support `GOOGLE_API_KEY`
- Added automatic provider detection (Gemini vs OpenAI vs Azure)
- Implemented cross-encoder (reranker) support for Gemini
- Updated logging to show which provider is being used

#### 2. Dependencies (`mcp_server/pyproject.toml`)
- Changed `graphiti-core>=0.14.0` to `graphiti-core[google-genai]>=0.14.0`
- Added direct `google-genai` dependency to root `pyproject.toml`

#### 3. Configuration Files
- **`.env.example`**: Added Gemini configuration examples with proper model names
- **`docker-compose.yml`**: Added `GOOGLE_API_KEY` and `SMALL_MODEL_NAME` environment variables

#### 4. Documentation (`mcp_server/README.md`)
- Added comprehensive Gemini setup section
- Documented environment variable options
- Added link to Google AI Studio for API key creation
- Clarified LLM provider selection process

### Technical Decisions

#### Environment-Based Provider Selection
```
Priority: GOOGLE_API_KEY → AZURE_OPENAI_ENDPOINT → OPENAI_API_KEY
```
- Server automatically detects which provider to use based on available API keys
- No code changes needed to switch providers - only environment variables

#### Model Defaults for Gemini
- **Main Model**: `gemini-2.5-flash` (for LLM operations)
- **Small Model**: `gemini-2.5-flash-lite-preview-06-17` (for reranking)
- **Embedding Model**: `gemini-embedding-001` (Gemini's preferred embedding model)

#### Cross-Encoder Integration
- Added `create_cross_encoder_client()` method to LLM configuration
- Supports both Gemini and OpenAI rerankers
- Integrated into Graphiti initialization process

### Neo4j Integration Notes
- **Recommended URL**: `neo4j://127.0.0.1:7687` (supports routing, more future-proof than `bolt://`)
- **Neo4j Desktop**: Preferred for development (survives reboots, GUI management)
- **Terminology**: Project → Instance/DBMS → Database (hierarchical structure)

### Deployment Options
1. **uv (Recommended for forks)**: Direct code execution, easier upstream syncing
2. **Docker Compose**: Requires local build due to custom changes
3. **Neo4j Desktop + uv**: Best hybrid approach for development

### Fork Maintenance Strategy
- Changes isolated to MCP server layer only
- No modifications to core Graphiti library
- Minimal, additive changes to reduce merge conflicts
- Environment-based configuration for easy switching

## Current Status
- ✅ Gemini integration fully functional
- ✅ Backward compatibility maintained
- ✅ Documentation updated
- ✅ Testing completed successfully
- ✅ Claude Code MCP integration configured
- ✅ Transport issues resolved (STDIO as default)
- ✅ User scope installation working
- 🎯 Production ready and actively in use

## Session Summary (2025-08-28)
### Initial Session Tasks Completed
1. **Core Gemini Integration**: Replaced OpenAI with Gemini as primary LLM provider
2. **Embedding Model Configuration**: Set gemini-embedding-001 as default embedding model
3. **Claude Code Integration**: Provided complete setup instructions for MCP integration
4. **Transport Optimization**: Changed default from SSE to STDIO to prevent port conflicts
5. **User Experience**: Resolved installation and connection issues, cleaned up temporary files

### Continued Session Tasks Completed
1. **Neo4j Integration**: Diagnosed database visibility issues between MCP server and Neo4j Desktop
2. **Security Fix**: Corrected password hardcoding vulnerability in docker-compose.yml
3. **Docker Optimization**: Attempted and resolved Python environment conflicts in containerized setup
4. **Architecture Decision**: Established optimal hybrid approach (Docker Neo4j + local uv MCP)
5. **Documentation**: Provided complete configuration instructions for production setup

### User Feedback Addressed
- Fixed import errors with graceful error handling
- Resolved port 8000 conflicts by switching transport methods  
- Explained STDIO vs SSE differences in simple terms
- Assisted with user scope installation issues
- Removed unnecessary wrapper scripts per user request
- **Security concern**: Fixed hardcoded password exposure in version control
- **Docker issues**: Resolved Python virtual environment conflicts in containers

### Recommended Production Setup
**Optimal Configuration Established:**
1. **Neo4j**: Docker container with persistent volumes
2. **MCP Server**: Local uv execution for development flexibility  
3. **Claude Code**: STDIO transport configuration
4. **Security**: Environment variables for all sensitive data

## Next Steps
- Monitor upstream Graphiti changes for integration
- Consider contributing Gemini support back to upstream
- All core functionality implemented and production ready
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
- **Embedding Model**: `text-embedding-001` (Gemini's embedding model)

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
- 🎯 Ready for production use

## Next Steps
- Monitor upstream Graphiti changes for integration
- Consider contributing Gemini support back to upstream
- Add more comprehensive testing if needed
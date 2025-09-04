# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Graphiti is a Python framework for building temporally-aware knowledge graphs designed for AI agents. It enables real-time incremental updates to knowledge graphs without batch recomputation, making it suitable for dynamic environments.

Key features:

- Bi-temporal data model with explicit tracking of event occurrence times
- Hybrid retrieval combining semantic embeddings, keyword search (BM25), and graph traversal
- Support for custom entity definitions via Pydantic models
- Integration with Neo4j, FalkorDB, Kuzu, and Amazon Neptune as graph storage backends
- MCP (Model Context Protocol) server for AI assistant integration

## Development Commands

### Main Development Commands (run from project root)

```bash
# Install dependencies
uv sync --extra dev

# Format code (ruff import sorting + formatting)
make format

# Lint code (ruff + pyright type checking)
make lint

# Run tests
make test

# Run all checks (format, lint, test)
make check
```

### Server Development (run from server/ directory)

```bash
cd server/
# Install server dependencies
uv sync --extra dev

# Run server in development mode
uvicorn graph_service.main:app --reload

# Format, lint, test server code
make format
make lint
make test
```

### MCP Server Development (run from mcp_server/ directory)

```bash
cd mcp_server/
# Install MCP server dependencies
uv sync

# Run with Docker Compose
docker-compose up

# Run MCP server directly (requires Neo4j running)
uv run python graphiti_mcp_server.py
```

### Running Single Tests

```bash
# Run specific test file
pytest tests/test_specific_file.py

# Run specific test method
pytest tests/test_file.py::test_method_name

# Run only integration tests (require database)
pytest tests/ -k "_int"

# Run only unit tests
pytest tests/ -k "not _int"

# Run tests with verbose output
pytest -v tests/

# Run tests in parallel (faster)
pytest -n auto tests/
```

## Code Architecture

### Core Library (`graphiti_core/`)

- **Main Entry Point**: `graphiti.py` - Contains the main `Graphiti` class that orchestrates all functionality
- **Graph Storage**: `driver/` - Database drivers for Neo4j and FalkorDB
- **LLM Integration**: `llm_client/` - Clients for OpenAI, Anthropic, Gemini, Groq
- **Embeddings**: `embedder/` - Embedding clients for various providers
- **Graph Elements**: `nodes.py`, `edges.py` - Core graph data structures
- **Search**: `search/` - Hybrid search implementation with configurable strategies
- **Prompts**: `prompts/` - LLM prompts for entity extraction, deduplication, summarization
- **Utilities**: `utils/` - Maintenance operations, bulk processing, datetime handling

### Server (`server/`)

- **FastAPI Service**: `graph_service/main.py` - REST API server
- **Routers**: `routers/` - API endpoints for ingestion and retrieval
- **DTOs**: `dto/` - Data transfer objects for API contracts

### MCP Server (`mcp_server/`)

- **MCP Implementation**: `graphiti_mcp_server.py` - Model Context Protocol server for AI assistants
- **Docker Support**: Containerized deployment with Neo4j
- **Usage Guidelines**: `docs/cursor_rules.md` - Best practices for MCP integration

## Testing

- **Unit Tests**: `tests/` - Comprehensive test suite using pytest
- **Integration Tests**: Tests marked with `_int` suffix require database connections
- **Evaluation**: `tests/evals/` - End-to-end evaluation scripts

## Configuration

### Environment Variables

- `OPENAI_API_KEY` - Required for LLM inference and embeddings
- `USE_PARALLEL_RUNTIME` - Optional boolean for Neo4j parallel runtime (enterprise only)
- Provider-specific keys: `ANTHROPIC_API_KEY`, `GOOGLE_API_KEY`, `GROQ_API_KEY`, `VOYAGE_API_KEY`

### Database Setup

- **Neo4j**: Version 5.26+ required, available via Neo4j Desktop
  - Database name defaults to `neo4j` (hardcoded in Neo4jDriver)
  - Override by passing `database` parameter to driver constructor
- **FalkorDB**: Version 1.1.2+ as alternative backend
  - Database name defaults to `default_db` (hardcoded in FalkorDriver)
  - Override by passing `database` parameter to driver constructor
- **Kuzu**: Version 0.11.2+ as lightweight embedded option
- **Amazon Neptune**: Cloud-managed graph database with OpenSearch integration

## Development Guidelines

### Code Style

- Use Ruff for formatting and linting (configured in pyproject.toml)
- Line length: 100 characters
- Quote style: single quotes
- Type checking with Pyright is enforced
- Main project uses `typeCheckingMode = "basic"`, server uses `typeCheckingMode = "standard"`

### Pre-Commit Requirements

**IMPORTANT:** Always format and lint code before committing:

```bash
# Format code (required before commit)
make format  # or: uv run ruff format

# Lint code (required before commit)
make lint    # or: uv run ruff check --fix && uv run pyright

# Run all checks (format + lint + test)
make check
```

**Never commit code without running these commands first.** This ensures code quality and consistency across the codebase.

### Testing Requirements

- Run tests with `make test` or `pytest`
- Integration tests require database connections and are marked with `_int` suffix
- Use `pytest-xdist` for parallel test execution
- Run specific test files: `pytest tests/test_specific_file.py`
- Run specific test methods: `pytest tests/test_file.py::test_method_name`
- Run only integration tests: `pytest tests/ -k "_int"`
- Run only unit tests: `pytest tests/ -k "not _int"`

### LLM Provider Support

The codebase supports multiple LLM providers but works best with services supporting structured output (OpenAI, Gemini). Other providers may cause schema validation issues, especially with smaller models.

Supported providers:
- **OpenAI**: Full support including Azure OpenAI (requires v1 API opt-in for structured outputs)
- **Google Gemini**: Full support with structured outputs
- **Anthropic**: Supported via `anthropic` extra dependency
- **Groq**: Supported via `groq` extra dependency

### Development Workflow Patterns

#### Core Library Development
The main entry point is `graphiti_core/graphiti.py` which orchestrates:
1. **Data Ingestion**: Episodes are processed through LLM clients for entity extraction
2. **Graph Storage**: Entities and edges are persisted via database drivers
3. **Search Operations**: Hybrid retrieval combines semantic, keyword (BM25), and graph traversal
4. **Temporal Operations**: Bi-temporal model tracks both occurrence and ingestion times

#### Adding New Database Drivers
1. Implement the `Driver` interface from `graphiti_core/driver/driver.py`
2. Follow patterns in existing drivers (`neo4j_driver.py`, `falkordb_driver.py`)
3. Add database-specific dependencies to `pyproject.toml` optional dependencies
4. Add integration tests with `_int` suffix in test file names

### MCP Server Usage Guidelines

When working with the MCP server, follow the patterns established in `mcp_server/docs/cursor_rules.md`:

- **Always search first**: Use `search_nodes` and `search_facts` tools before beginning work
- **Filter by entity type**: Specify `Preference`, `Procedure`, or `Requirement` for targeted results
- **Save immediately**: Use `add_memory` to capture new requirements and preferences right away
- **Be explicit about updates**: Only add what's changed or new to the graph
- **Stay consistent**: Respect discovered preferences and follow established procedures

### Project Structure Insights

```
graphiti/
├── graphiti_core/           # Core library - main development focus
│   ├── graphiti.py         # Primary orchestration class
│   ├── driver/             # Database abstraction layer
│   ├── llm_client/         # LLM provider integrations
│   ├── embedder/           # Embedding provider integrations  
│   ├── search/             # Hybrid search implementation
│   ├── prompts/            # LLM prompt templates
│   └── utils/              # Maintenance and utility operations
├── server/                 # FastAPI REST API service
│   ├── graph_service/      # Main FastAPI application
│   └── routers/            # API endpoint definitions
├── mcp_server/            # Model Context Protocol server
│   ├── graphiti_mcp_server.py  # MCP implementation
│   └── docs/cursor_rules.md    # MCP usage guidelines
└── tests/                 # Comprehensive test suite
    ├── evals/             # End-to-end evaluation scripts
    └── *_int*             # Integration tests (require database)
```
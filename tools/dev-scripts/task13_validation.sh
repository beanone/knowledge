#!/bin/bash
# tools/dev-scripts/task13_validation.sh
# Validates MCP Integration implementation

set -e

# Ensure we're in the project root
cd "$(git rev-parse --show-toplevel)"

source .venv/bin/activate

# Validate implementation
function validate_implementation() {
  cd knowledge/packages/graph-api

  # Check required files
  required_files=(
    "src/mcp/routes.py"
    "src/mcp/tools.py"
    "src/mcp/schemas.py"
    "src/mcp/agent_config.py"
    "src/mcp/semantic_descriptions.py"
  )

  for file in "${required_files[@]}"; do
    if [ ! -f "$file" ]; then
      echo "❌ Missing required file: $file"
      exit 1
    fi
  done

  # Validate type checking
  if ! mypy src/mcp/; then
    echo "❌ Type checking failed"
    exit 1
  fi

  # Validate code style
  if ! ruff check src/mcp/; then
    echo "❌ Code style validation failed"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate FastAPI_MCP integration
function validate_fastapi_mcp() {
  cd knowledge/packages/graph-api

  # Run FastAPI_MCP integration tests
  if ! pytest tests/mcp/test_integration.py \
      --cov=src/mcp \
      --cov-report=term-missing \
      --cov-fail-under=90; then
    echo "❌ FastAPI_MCP integration tests failed or coverage below 90%"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate semantic API descriptions
function validate_semantic_descriptions() {
  cd knowledge/packages/graph-api

  # Run semantic description tests
  if ! pytest tests/mcp/test_semantic_descriptions.py \
      --cov=src/mcp/semantic_descriptions.py \
      --cov-report=term-missing \
      --cov-fail-under=90; then
    echo "❌ Semantic description tests failed or coverage below 90%"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate agent endpoints
function validate_agent_endpoints() {
  cd knowledge/packages/graph-api

  # Run agent endpoint tests
  if ! pytest tests/mcp/test_agent_endpoints.py \
      --cov=src/mcp/routes.py \
      --cov-report=term-missing \
      --cov-fail-under=90; then
    echo "❌ Agent endpoint tests failed or coverage below 90%"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate MCP tools
function validate_mcp_tools() {
  cd knowledge/packages/graph-api

  # Run MCP tools tests
  if ! pytest tests/mcp/test_tools.py \
      --cov=src/mcp/tools.py \
      --cov-report=term-missing \
      --cov-fail-under=90; then
    echo "❌ MCP tools tests failed or coverage below 90%"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Run all validations
validate_implementation
validate_fastapi_mcp
validate_semantic_descriptions
validate_agent_endpoints
validate_mcp_tools

echo "✅ MCP Integration implementation validated"
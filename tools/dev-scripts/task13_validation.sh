#!/bin/bash
# tools/dev-scripts/task13_validation.sh
# Validates MCP Integration implementation

set -e

# Ensure we're in the project root
cd "$(git rev-parse --show-toplevel)"

source .venv/bin/activate

# Validate directory structure
function validate_directory_structure() {
  cd knowledge/packages/graph-api

  # Check required directories
  required_dirs=(
    "src/mcp"
    "src/services"
    "src/templates/semantic"
    "tests/mcp"
    "tests/services"
    "tests/integration"
  )

  for dir in "${required_dirs[@]}"; do
    if [ ! -d "$dir" ]; then
      echo "❌ Missing required directory: $dir"
      exit 1
    fi
  done

  # Check required files
  required_files=(
    "src/mcp/__init__.py"
    "src/mcp/routes.py"
    "src/mcp/tools.py"
    "src/mcp/schemas.py"
    "src/mcp/agents.py"
    "src/services/__init__.py"
    "src/services/mcp_manager.py"
    "src/templates/__init__.py"
    "src/templates/semantic/__init__.py"
    "src/templates/semantic/entities.yaml"
    "src/templates/semantic/relations.yaml"
    "src/templates/semantic/queries.yaml"
    "src/__init__.py"
    "tests/mcp/__init__.py"
    "tests/mcp/test_routes.py"
    "tests/mcp/test_tools.py"
    "tests/mcp/test_schemas.py"
    "tests/mcp/test_agents.py"
    "tests/services/__init__.py"
    "tests/services/test_mcp_manager.py"
    "tests/integration/__init__.py"
    "tests/integration/test_mcp_api.py"
  )

  for file in "${required_files[@]}"; do
    if [ ! -f "$file" ]; then
      echo "❌ Missing required file: $file"
      exit 1
    fi
  done

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate API implementation
function validate_api() {
  cd knowledge/packages/graph-api

  # Validate type checking
  if ! mypy src/mcp/ src/services/mcp_manager.py; then
    echo "❌ Type checking failed"
    exit 1
  fi

  # Validate code style
  if ! ruff check src/mcp/ src/services/mcp_manager.py; then
    echo "❌ Code style validation failed"
    exit 1
  fi

  # Validate OpenAPI documentation
  if ! python -c "from fastapi.openapi.utils import get_openapi; from src.main import app; spec = get_openapi(title=app.title, version=app.version, routes=app.routes); assert any('/mcp' in path for path in spec['paths'])"; then
    echo "❌ OpenAPI documentation validation failed"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate MCP routes and tools
function validate_mcp_components() {
  cd knowledge/packages/graph-api

  # Run MCP component tests
  if ! pytest tests/mcp/ \
      --cov=src/mcp \
      --cov-report=term-missing \
      --cov-fail-under=90; then
    echo "❌ MCP component tests failed or coverage below 90%"
    exit 1
  fi

  # Validate tool implementations
  if ! python -c "from src.mcp.tools import GraphTools; assert all(hasattr(GraphTools, op) for op in ['create_entity', 'update_entity', 'delete_entity', 'create_relation', 'update_relation', 'delete_relation', 'query', 'traverse'])"; then
    echo "❌ MCP tools missing required graph operations"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate semantic descriptions
function validate_semantic_descriptions() {
  cd knowledge/packages/graph-api

  # Check YAML validity
  for file in src/templates/semantic/*.yaml; do
    if ! python -c "import yaml; yaml.safe_load(open('$file'))"; then
      echo "❌ Invalid YAML in semantic description: $file"
      exit 1
    fi
  done

  # Check semantic content
  if ! python -c "
    import yaml
    entities = yaml.safe_load(open('src/templates/semantic/entities.yaml'))
    relations = yaml.safe_load(open('src/templates/semantic/relations.yaml'))
    queries = yaml.safe_load(open('src/templates/semantic/queries.yaml'))
    assert all('description' in doc for doc in [entities, relations, queries])
    assert all('examples' in doc for doc in [entities, relations, queries])
    "; then
    echo "❌ Semantic descriptions missing required content"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate GraphBuilder integration
function validate_graphbuilder_integration() {
  cd knowledge/packages/graph-api

  # Check GraphBuilder integration
  if ! python -c "from src.mcp.tools import GraphTools; from src.services.graph_builder import GraphBuilder; assert any(issubclass(tool, GraphBuilder) for tool in GraphTools.__subclasses__())"; then
    echo "❌ MCP tools not properly integrated with GraphBuilder"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate integration
function validate_integration() {
  cd knowledge/packages/graph-api

  # Run integration tests
  if ! pytest tests/integration/test_mcp_api.py; then
    echo "❌ Integration tests failed"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Run all validations
echo "Validating directory structure..."
validate_directory_structure

echo "Validating API implementation..."
validate_api

echo "Validating MCP components..."
validate_mcp_components

echo "Validating semantic descriptions..."
validate_semantic_descriptions

echo "Validating GraphBuilder integration..."
validate_graphbuilder_integration

echo "Validating integration..."
validate_integration

echo "✅ MCP Integration implementation validated"
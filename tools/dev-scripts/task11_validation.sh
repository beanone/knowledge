#!/bin/bash
# tools/dev-scripts/task11_validation.sh
# Validates Query API implementation

set -e

# Ensure we're in the project root
cd "$(git rev-parse --show-toplevel)"

source .venv/bin/activate

# Validate directory structure
function validate_directory_structure() {
  cd knowledge/packages/graph-api

  # Check required directories
  required_dirs=(
    "src/routes"
    "src/schemas"
    "src/services"
    "tests/routes"
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
    "src/routes/__init__.py"
    "src/routes/query.py"
    "src/routes/traversal.py"
    "src/schemas/__init__.py"
    "src/schemas/query.py"
    "src/schemas/traversal.py"
    "src/services/__init__.py"
    "src/services/query_executor.py"
    "src/services/search.py"
    "src/__init__.py"
    "tests/routes/__init__.py"
    "tests/routes/test_query.py"
    "tests/routes/test_traversal.py"
    "tests/services/__init__.py"
    "tests/services/test_query_executor.py"
    "tests/services/test_search.py"
    "tests/integration/__init__.py"
    "tests/integration/test_query_api.py"
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
  if ! mypy src/routes/query.py src/routes/traversal.py \
          src/schemas/query.py src/schemas/traversal.py \
          src/services/query_executor.py src/services/search.py; then
    echo "❌ Type checking failed"
    exit 1
  fi

  # Validate code style
  if ! ruff check src/routes/query.py src/routes/traversal.py \
          src/schemas/query.py src/schemas/traversal.py \
          src/services/query_executor.py src/services/search.py; then
    echo "❌ Code style validation failed"
    exit 1
  fi

  # Validate OpenAPI documentation
  if ! python -c "from fastapi.openapi.utils import get_openapi; from src.main import app; spec = get_openapi(title=app.title, version=app.version, routes=app.routes); assert any('/query' in path or '/traversal' in path for path in spec['paths'])"; then
    echo "❌ OpenAPI documentation validation failed"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate query functionality
function validate_query() {
  cd knowledge/packages/graph-api

  # Run query endpoint tests
  if ! pytest tests/routes/test_query.py \
      --cov=src/routes/query.py \
      --cov-report=term-missing \
      --cov-fail-under=90; then
    echo "❌ Query endpoint tests failed or coverage below 90%"
    exit 1
  fi

  # Run query executor tests
  if ! pytest tests/services/test_query_executor.py \
      --cov=src/services/query_executor.py \
      --cov-report=term-missing \
      --cov-fail-under=90; then
    echo "❌ Query executor tests failed or coverage below 90%"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate traversal functionality
function validate_traversal() {
  cd knowledge/packages/graph-api

  # Run traversal endpoint tests
  if ! pytest tests/routes/test_traversal.py \
      --cov=src/routes/traversal.py \
      --cov-report=term-missing \
      --cov-fail-under=90; then
    echo "❌ Traversal endpoint tests failed or coverage below 90%"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate search functionality
function validate_search() {
  cd knowledge/packages/graph-api

  # Run search service tests
  if ! pytest tests/services/test_search.py \
      --cov=src/services/search.py \
      --cov-report=term-missing \
      --cov-fail-under=90; then
    echo "❌ Search service tests failed or coverage below 90%"
    exit 1
  fi

  # Validate pagination implementation
  if ! python -c "from src.services.search import SearchService; assert hasattr(SearchService, 'paginate')"; then
    echo "❌ Search service missing pagination functionality"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate integration
function validate_integration() {
  cd knowledge/packages/graph-api

  # Run integration tests
  if ! pytest tests/integration/test_query_api.py; then
    echo "❌ Integration tests failed"
    exit 1
  fi

  # Validate service integrations
  if ! python -c "from src.services.query_executor import QueryExecutor; from src.services.graph_manager import GraphManager; assert issubclass(QueryExecutor, GraphManager)"; then
    echo "❌ Query executor is not properly integrated with GraphManager"
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

echo "Validating query functionality..."
validate_query

echo "Validating traversal functionality..."
validate_traversal

echo "Validating search functionality..."
validate_search

echo "Validating integration..."
validate_integration

echo "✅ Query API implementation validated"
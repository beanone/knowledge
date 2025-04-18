#!/bin/bash
# tools/dev-scripts/task11_validation.sh
# Validates Query API implementation

set -e

# Ensure we're in the project root
cd "$(git rev-parse --show-toplevel)"

source .venv/bin/activate

# Validate API implementation
function validate_api() {
  cd knowledge/packages/graph-api

  # Check required API files
  required_files=(
    "src/routes/query.py"
    "src/routes/traversal.py"
    "src/routes/search.py"
    "src/schemas/query.py"
    "src/services/query_executor.py"
  )

  for file in "${required_files[@]}"; do
    if [ ! -f "$file" ]; then
      echo "❌ Missing required file: $file"
      exit 1
    fi
  done

  # Validate type checking
  if ! mypy src/routes/query.py src/routes/traversal.py src/routes/search.py \
          src/schemas/query.py src/services/query_executor.py; then
    echo "❌ Type checking failed"
    exit 1
  fi

  # Validate code style
  if ! ruff check src/routes/query.py src/routes/traversal.py src/routes/search.py \
          src/schemas/query.py src/services/query_executor.py; then
    echo "❌ Code style validation failed"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate query endpoints
function validate_query_endpoints() {
  cd knowledge/packages/graph-api

  # Run query endpoint tests
  if ! pytest tests/routes/test_query.py \
      --cov=src/routes/query.py \
      --cov-report=term-missing \
      --cov-fail-under=90; then
    echo "❌ Query endpoint tests failed or coverage below 90%"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate traversal functionality
function validate_traversal() {
  cd knowledge/packages/graph-api

  # Run traversal tests
  if ! pytest tests/routes/test_traversal.py \
      --cov=src/routes/traversal.py \
      --cov-report=term-missing \
      --cov-fail-under=90; then
    echo "❌ Traversal tests failed or coverage below 90%"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate search functionality
function validate_search() {
  cd knowledge/packages/graph-api

  # Run search tests
  if ! pytest tests/routes/test_search.py \
      --cov=src/routes/search.py \
      --cov-report=term-missing \
      --cov-fail-under=90; then
    echo "❌ Search tests failed or coverage below 90%"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Run integration tests
function validate_integration() {
  cd knowledge/packages/graph-api

  # Run integration tests
  if ! pytest tests/integration/test_query_api.py; then
    echo "❌ Query API integration tests failed"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Run all validations
validate_api
validate_query_endpoints
validate_traversal
validate_search
validate_integration

echo "✅ Query API implementation validated"
#!/bin/bash
# tools/dev-scripts/task19_validation.sh
# Validates FileDB Connector implementation

set -e

# Ensure we're in the project root
cd "$(git rev-parse --show-toplevel)"

source .venv/bin/activate

# Validate implementation
function validate_implementation() {
  cd knowledge/packages/graph-core

  # Check required files
  required_files=(
    "src/backends/filedb/connector.py"
    "src/backends/filedb/storage.py"
    "src/backends/filedb/indexing.py"
    "src/backends/filedb/query.py"
    "src/backends/filedb/transaction.py"
    "src/backends/filedb/utils.py"
    "src/backends/filedb/__init__.py"
  )

  for file in "${required_files[@]}"; do
    if [ ! -f "$file" ]; then
      echo "❌ Missing required file: $file"
      exit 1
    fi
  done

  # Validate type checking
  if ! mypy src/backends/filedb/; then
    echo "❌ Type checking failed"
    exit 1
  fi

  # Validate code style
  if ! ruff check src/backends/filedb/; then
    echo "❌ Code style validation failed"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate CRUD operations
function validate_crud_operations() {
  cd knowledge/packages/graph-core

  # Run CRUD tests
  if ! pytest tests/backends/filedb/test_crud.py \
      --cov=src/backends/filedb \
      --cov-report=term-missing \
      --cov-fail-under=95; then
    echo "❌ CRUD tests failed or coverage below 95%"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate persistence
function validate_persistence() {
  cd knowledge/packages/graph-core

  # Run persistence tests
  if ! pytest tests/backends/filedb/test_persistence.py \
      --cov=src/backends/filedb/storage.py \
      --cov-report=term-missing \
      --cov-fail-under=95; then
    echo "❌ Persistence tests failed or coverage below 95%"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate indexing
function validate_indexing() {
  cd knowledge/packages/graph-core

  # Run indexing tests
  if ! pytest tests/backends/filedb/test_indexing.py \
      --cov=src/backends/filedb/indexing.py \
      --cov-report=term-missing \
      --cov-fail-under=95; then
    echo "❌ Indexing tests failed or coverage below 95%"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate query execution
function validate_query_execution() {
  cd knowledge/packages/graph-core

  # Run query tests
  if ! pytest tests/backends/filedb/test_query.py \
      --cov=src/backends/filedb/query.py \
      --cov-report=term-missing \
      --cov-fail-under=95; then
    echo "❌ Query execution tests failed or coverage below 95%"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate development helpers
function validate_development_helpers() {
  cd knowledge/packages/graph-core

  # Run helper tests
  if ! pytest tests/backends/filedb/test_utils.py \
      --cov=src/backends/filedb/utils.py \
      --cov-report=term-missing \
      --cov-fail-under=95; then
    echo "❌ Development helper tests failed or coverage below 95%"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate integration
function validate_integration() {
  cd knowledge/packages/graph-core

  # Run integration tests
  if ! pytest tests/backends/filedb/test_integration.py; then
    echo "❌ Integration tests failed"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Run all validations
validate_implementation
validate_crud_operations
validate_persistence
validate_indexing
validate_query_execution
validate_development_helpers
validate_integration

echo "✅ FileDB Connector implementation validated"
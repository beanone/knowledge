#!/bin/bash
# tools/dev-scripts/task4_validation.sh
# Validates Neo4j Backend Connector implementation

set -e

# Ensure we're in the project root
cd "$(git rev-parse --show-toplevel)"

source .venv/bin/activate

# Validate Neo4j connector implementation
function validate_connector() {
  cd knowledge/packages/graph-core

  # Check required connector files
  required_files=(
    "src/backends/neo4j/connector.py"
    "src/backends/neo4j/queries.py"
    "src/backends/neo4j/transaction.py"
    "src/backends/neo4j/schema.py"
  )

  for file in "${required_files[@]}"; do
    if [ ! -f "$file" ]; then
      echo "❌ Missing required file: $file"
      exit 1
    fi
  done

  # Validate type checking
  if ! mypy src/backends/neo4j; then
    echo "❌ Type checking failed"
    exit 1
  fi

  # Validate code style
  if ! ruff check src/backends/neo4j; then
    echo "❌ Code style validation failed"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate CRUD operations
function validate_crud() {
  cd knowledge/packages/graph-core

  # Run CRUD-specific tests
  if ! pytest tests/backends/neo4j/test_crud.py \
      --cov=src/backends/neo4j \
      --cov-report=term-missing \
      --cov-fail-under=95; then
    echo "❌ CRUD tests failed or coverage below 95%"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate query functionality
function validate_querying() {
  cd knowledge/packages/graph-core

  # Run query-specific tests
  if ! pytest tests/backends/neo4j/test_queries.py \
      --cov=src/backends/neo4j/queries.py \
      --cov-report=term-missing \
      --cov-fail-under=95; then
    echo "❌ Query tests failed or coverage below 95%"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Run integration tests
function validate_integration() {
  cd knowledge/packages/graph-core

  # Run integration tests
  if ! pytest tests/integration/test_neo4j_integration.py; then
    echo "❌ Integration tests failed"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Run all validations
validate_connector
validate_crud
validate_querying
validate_integration

echo "✅ Neo4j backend connector implementation validated"
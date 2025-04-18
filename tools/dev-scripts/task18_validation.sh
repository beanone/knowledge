#!/bin/bash
# tools/dev-scripts/task18_validation.sh
# Validates ArangoDB Connector implementation

set -e

# Ensure we're in the project root
cd "$(git rev-parse --show-toplevel)"

source .venv/bin/activate

# Validate implementation
function validate_implementation() {
  cd knowledge/packages/graph-core

  # Check required files
  required_files=(
    "src/backends/arango/connector.py"
    "src/backends/arango/query_builder.py"
    "src/backends/arango/schema_manager.py"
    "src/backends/arango/transaction.py"
    "src/backends/arango/utils.py"
    "src/backends/arango/__init__.py"
  )

  for file in "${required_files[@]}"; do
    if [ ! -f "$file" ]; then
      echo "❌ Missing required file: $file"
      exit 1
    fi
  done

  # Validate type checking
  if ! mypy src/backends/arango/; then
    echo "❌ Type checking failed"
    exit 1
  fi

  # Validate code style
  if ! ruff check src/backends/arango/; then
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
  if ! pytest tests/backends/arango/test_crud.py \
      --cov=src/backends/arango \
      --cov-report=term-missing \
      --cov-fail-under=95; then
    echo "❌ CRUD tests failed or coverage below 95%"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate transaction handling
function validate_transactions() {
  cd knowledge/packages/graph-core

  # Run transaction tests
  if ! pytest tests/backends/arango/test_transaction.py \
      --cov=src/backends/arango/transaction.py \
      --cov-report=term-missing \
      --cov-fail-under=95; then
    echo "❌ Transaction tests failed or coverage below 95%"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate query building
function validate_query_building() {
  cd knowledge/packages/graph-core

  # Run query builder tests
  if ! pytest tests/backends/arango/test_query_builder.py \
      --cov=src/backends/arango/query_builder.py \
      --cov-report=term-missing \
      --cov-fail-under=95; then
    echo "❌ Query builder tests failed or coverage below 95%"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate specialized features
function validate_specialized_features() {
  cd knowledge/packages/graph-core

  # Run specialized feature tests
  if ! pytest tests/backends/arango/test_specialized.py \
      --cov=src/backends/arango \
      --cov-report=term-missing \
      --cov-fail-under=95; then
    echo "❌ Specialized feature tests failed or coverage below 95%"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate integration
function validate_integration() {
  cd knowledge/packages/graph-core

  # Run integration tests
  if ! pytest tests/backends/arango/test_integration.py; then
    echo "❌ Integration tests failed"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Run all validations
validate_implementation
validate_crud_operations
validate_transactions
validate_query_building
validate_specialized_features
validate_integration

echo "✅ ArangoDB Connector implementation validated"
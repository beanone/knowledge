#!/bin/bash
# tools/dev-scripts/task5_validation.sh
# Validates GraphManager Service implementation

set -e

# Ensure we're in the project root
cd "$(git rev-parse --show-toplevel)"

source .venv/bin/activate

# Validate service implementation
function validate_service() {
  cd knowledge/packages/graph-service

  # Check required service files
  required_files=(
    "src/services/graph_manager.py"
    "src/services/transaction.py"
    "src/services/error_handling.py"
  )

  for file in "${required_files[@]}"; do
    if [ ! -f "$file" ]; then
      echo "❌ Missing required file: $file"
      exit 1
    fi
  done

  # Validate type checking
  if ! mypy src/services; then
    echo "❌ Type checking failed"
    exit 1
  fi

  # Validate code style
  if ! ruff check src/services; then
    echo "❌ Code style validation failed"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate transaction management
function validate_transactions() {
  cd knowledge/packages/graph-service

  # Run transaction-specific tests
  if ! pytest tests/services/test_transactions.py \
      --cov=src/services/transaction.py \
      --cov-report=term-missing \
      --cov-fail-under=90; then
    echo "❌ Transaction tests failed or coverage below 90%"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate multi-step operations
function validate_operations() {
  cd knowledge/packages/graph-service

  # Run operation-specific tests
  if ! pytest tests/services/test_operations.py \
      --cov=src/services/graph_manager.py \
      --cov-report=term-missing \
      --cov-fail-under=90; then
    echo "❌ Operation tests failed or coverage below 90%"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate error handling
function validate_error_handling() {
  cd knowledge/packages/graph-service

  # Run error handling tests
  if ! pytest tests/services/test_error_handling.py \
      --cov=src/services/error_handling.py \
      --cov-report=term-missing \
      --cov-fail-under=90; then
    echo "❌ Error handling tests failed or coverage below 90%"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Run all validations
validate_service
validate_transactions
validate_operations
validate_error_handling

echo "✅ GraphManager Service implementation validated"
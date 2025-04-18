#!/bin/bash
# tools/dev-scripts/task8_validation.sh
# Validates QueryService implementation

set -e

# Ensure we're in the project root
cd "$(git rev-parse --show-toplevel)"

source .venv/bin/activate

# Validate service implementation
function validate_service() {
  cd knowledge/packages/graph-service

  # Check required service files
  required_files=(
    "src/services/query_service.py"
    "src/services/query_builder.py"
    "src/services/result_formatter.py"
    "src/services/pagination.py"
  )

  for file in "${required_files[@]}"; do
    if [ ! -f "$file" ]; then
      echo "❌ Missing required file: $file"
      exit 1
    fi
  done

  # Validate type checking
  if ! mypy src/services/query_service.py src/services/query_builder.py \
          src/services/result_formatter.py src/services/pagination.py; then
    echo "❌ Type checking failed"
    exit 1
  fi

  # Validate code style
  if ! ruff check src/services/query_service.py src/services/query_builder.py \
          src/services/result_formatter.py src/services/pagination.py; then
    echo "❌ Code style validation failed"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate query builder
function validate_query_builder() {
  cd knowledge/packages/graph-service

  # Run query builder tests
  if ! pytest tests/services/test_query_builder.py \
      --cov=src/services/query_builder.py \
      --cov-report=term-missing \
      --cov-fail-under=90; then
    echo "❌ Query builder tests failed or coverage below 90%"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate result formatting
function validate_result_formatting() {
  cd knowledge/packages/graph-service

  # Run result formatting tests
  if ! pytest tests/services/test_result_formatter.py \
      --cov=src/services/result_formatter.py \
      --cov-report=term-missing \
      --cov-fail-under=90; then
    echo "❌ Result formatting tests failed or coverage below 90%"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate pagination
function validate_pagination() {
  cd knowledge/packages/graph-service

  # Run pagination tests
  if ! pytest tests/services/test_pagination.py \
      --cov=src/services/pagination.py \
      --cov-report=term-missing \
      --cov-fail-under=90; then
    echo "❌ Pagination tests failed or coverage below 90%"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Run all validations
validate_service
validate_query_builder
validate_result_formatting
validate_pagination

echo "✅ QueryService implementation validated"
#!/bin/bash
# tools/dev-scripts/task2_validation.sh
# Validates GraphContext interface implementation

set -e

# Ensure we're in the project root
cd "$(git rev-parse --show-toplevel)"

source .venv/bin/activate

# Validate code structure and typing
function validate_code_structure() {
  cd knowledge/packages/graph-core

  # Check type hints
  if ! mypy src/graph_context; then
    echo "❌ Type checking failed"
    exit 1
  fi

  # Validate code formatting
  if ! ruff check src/graph_context; then
    echo "❌ Code style validation failed"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Run tests with coverage
function validate_tests() {
  cd knowledge/packages/graph-core

  # Run tests with coverage
  if ! pytest tests/graph_context \
      --cov=src/graph_context \
      --cov-report=term-missing \
      --cov-fail-under=95; then
    echo "❌ Tests failed or coverage below 95%"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate interface completeness
function validate_interface() {
  cd knowledge/packages/graph-core

  required_methods=(
    "create_entity"
    "get_entity"
    "update_entity"
    "delete_entity"
    "create_relation"
    "get_relation"
    "update_relation"
    "delete_relation"
    "query"
    "traverse"
  )

  for method in "${required_methods[@]}"; do
    if ! grep -q "def $method" src/graph_context/interface.py; then
      echo "❌ Missing required method: $method"
      exit 1
    fi
  done

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Run all validations
validate_code_structure
validate_tests
validate_interface

echo "✅ GraphContext implementation validated"
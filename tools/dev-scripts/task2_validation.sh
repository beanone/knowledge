#!/bin/bash
# tools/dev-scripts/task2_validation.sh
# Validates GraphContext interface implementation

set -e

# Ensure we're in the project root
cd "$(git rev-parse --show-toplevel)"

source .venv/bin/activate

# Validate directory structure
function validate_directory_structure() {
  cd knowledge/packages/graph-core

  # Check required directories exist
  required_dirs=(
    "src/graph_context"
    "src/types"
    "tests/graph_context"
    "tests/types"
  )

  for dir in "${required_dirs[@]}"; do
    if [ ! -d "$dir" ]; then
      echo "❌ Missing required directory: $dir"
      echo "Please ensure your directory structure matches the one specified in tasks.md"
      exit 1
    fi
  done

  # Check required files exist
  required_files=(
    "src/graph_context/__init__.py"
    "src/graph_context/interface.py"
    "src/graph_context/base.py"
    "src/graph_context/exceptions.py"
    "src/types/__init__.py"
    "src/types/base.py"
    "src/types/validators.py"
  )

  for file in "${required_files[@]}"; do
    if [ ! -f "$file" ]; then
      echo "❌ Missing required file: $file"
      echo "Please ensure your file structure matches the one specified in tasks.md"
      exit 1
    fi
  done

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate code structure and typing
function validate_code_structure() {
  cd knowledge/packages/graph-core

  # Check type hints
  if ! mypy src/graph_context; then
    echo "❌ Type checking failed"
    echo "Please ensure all code has proper type annotations"
    exit 1
  fi

  # Validate code formatting
  if ! ruff check src/graph_context; then
    echo "❌ Code style validation failed"
    echo "Please run 'ruff check --fix src/graph_context' to fix formatting issues"
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
    echo "Please ensure all tests pass and maintain at least 95% coverage"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate interface completeness
function validate_interface() {
  cd knowledge/packages/graph-core

  if [ ! -f "src/graph_context/interface.py" ]; then
    echo "❌ Missing interface.py file"
    echo "Please create src/graph_context/interface.py with the GraphContext interface"
    exit 1
  fi

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
      echo "❌ Missing required method: $method in interface.py"
      echo "Please implement all required methods as specified in tasks.md"
      exit 1
    fi
  done

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Run all validations
echo "Validating directory structure..."
validate_directory_structure

echo "Validating code structure and typing..."
validate_code_structure

echo "Running tests..."
validate_tests

echo "Validating interface completeness..."
validate_interface

echo "✅ GraphContext implementation validated successfully!"
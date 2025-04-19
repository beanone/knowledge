#!/bin/bash
# tools/dev-scripts/task6_validation.sh
# Validates EntityService implementation

set -e

# Ensure we're in the project root
cd "$(git rev-parse --show-toplevel)"

source .venv/bin/activate

# Validate directory structure
function validate_directory_structure() {
  cd knowledge/packages/graph-service

  # Check required directories exist
  required_dirs=(
    "src/entity_service"
    "tests/entity_service"
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
    "src/entity_service/__init__.py"
    "src/entity_service/service.py"
    "src/entity_service/workflows.py"
    "src/entity_service/properties.py"
    "src/entity_service/validation.py"
    "src/entity_service/utils.py"
    "tests/entity_service/__init__.py"
    "tests/entity_service/conftest.py"
    "tests/entity_service/test_service.py"
    "tests/entity_service/test_workflows.py"
    "tests/entity_service/test_properties.py"
    "tests/entity_service/test_validation.py"
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
  cd knowledge/packages/graph-service

  # Check type hints
  if ! mypy src/entity_service; then
    echo "❌ Type checking failed"
    echo "Please ensure all code has proper type annotations"
    exit 1
  fi

  # Validate code formatting
  if ! ruff check src/entity_service; then
    echo "❌ Code style validation failed"
    echo "Please run 'ruff check --fix src/entity_service' to fix formatting issues"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Run tests with coverage
function validate_tests() {
  cd knowledge/packages/graph-service

  # Run tests with coverage
  if ! pytest tests/entity_service \
      --cov=src/entity_service \
      --cov-report=term-missing \
      --cov-fail-under=90; then
    echo "❌ Tests failed or coverage below 90%"
    echo "Please ensure all tests pass and maintain at least 90% coverage"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate service integration
function validate_service_integration() {
  cd knowledge/packages/graph-service

  # Check if EntityService properly integrates with GraphManager
  if ! python -c "from entity_service.service import EntityService; from graph_manager.manager import GraphManager; assert any(base.__name__ == 'GraphManager' for base in EntityService.__bases__)"; then
    echo "❌ EntityService not properly integrated with GraphManager"
    echo "Please ensure EntityService extends or uses GraphManager"
    exit 1
  fi

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

echo "Validating service integration..."
validate_service_integration

echo "✅ EntityService implementation validated successfully!"
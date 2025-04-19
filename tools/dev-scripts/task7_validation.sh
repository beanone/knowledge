#!/bin/bash
# tools/dev-scripts/task7_validation.sh
# Validates RelationService implementation

set -e

# Ensure we're in the project root
cd "$(git rev-parse --show-toplevel)"

source .venv/bin/activate

# Validate directory structure
function validate_directory_structure() {
  cd knowledge/packages/graph-service

  # Check required directories exist
  required_dirs=(
    "src/relation_service"
    "tests/relation_service"
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
    "src/relation_service/__init__.py"
    "src/relation_service/service.py"
    "src/relation_service/endpoints.py"
    "src/relation_service/metadata.py"
    "src/relation_service/validation.py"
    "src/relation_service/utils.py"
    "tests/relation_service/__init__.py"
    "tests/relation_service/conftest.py"
    "tests/relation_service/test_service.py"
    "tests/relation_service/test_endpoints.py"
    "tests/relation_service/test_metadata.py"
    "tests/relation_service/test_validation.py"
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
  if ! mypy src/relation_service; then
    echo "❌ Type checking failed"
    echo "Please ensure all code has proper type annotations"
    exit 1
  fi

  # Validate code formatting
  if ! ruff check src/relation_service; then
    echo "❌ Code style validation failed"
    echo "Please run 'ruff check --fix src/relation_service' to fix formatting issues"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Run tests with coverage
function validate_tests() {
  cd knowledge/packages/graph-service

  # Run tests with coverage
  if ! pytest tests/relation_service \
      --cov=src/relation_service \
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

  # Check if RelationService properly integrates with required services
  if ! python -c "from relation_service.service import RelationService; from graph_manager.manager import GraphManager; from entity_service.service import EntityService; assert any(base.__name__ in ('GraphManager', 'EntityService') for base in RelationService.__bases__)"; then
    echo "❌ RelationService not properly integrated with GraphManager and EntityService"
    echo "Please ensure RelationService extends or uses both GraphManager and EntityService"
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

echo "✅ RelationService implementation validated successfully!"
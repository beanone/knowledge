#!/bin/bash
# tools/dev-scripts/task8_validation.sh
# Validates QueryService implementation

set -e

# Ensure we're in the project root
cd "$(git rev-parse --show-toplevel)"

source .venv/bin/activate

# Validate directory structure
function validate_directory_structure() {
  cd knowledge/packages/graph-service

  # Check required directories exist
  required_dirs=(
    "src/query_service"
    "tests/query_service"
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
    "src/query_service/__init__.py"
    "src/query_service/service.py"
    "src/query_service/builder.py"
    "src/query_service/formatter.py"
    "src/query_service/pagination.py"
    "src/query_service/utils.py"
    "tests/query_service/__init__.py"
    "tests/query_service/conftest.py"
    "tests/query_service/test_service.py"
    "tests/query_service/test_builder.py"
    "tests/query_service/test_formatter.py"
    "tests/query_service/test_pagination.py"
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
  if ! mypy src/query_service; then
    echo "❌ Type checking failed"
    echo "Please ensure all code has proper type annotations"
    exit 1
  fi

  # Validate code formatting
  if ! ruff check src/query_service; then
    echo "❌ Code style validation failed"
    echo "Please run 'ruff check --fix src/query_service' to fix formatting issues"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Run tests with coverage
function validate_tests() {
  cd knowledge/packages/graph-service

  # Run tests with coverage
  if ! pytest tests/query_service \
      --cov=src/query_service \
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

  # Check if QueryService properly integrates with required services
  if ! python -c "from query_service.service import QueryService; from graph_manager.manager import GraphManager; from entity_service.service import EntityService; from relation_service.service import RelationService; assert all(hasattr(QueryService, dep) for dep in ['graph_manager', 'entity_service', 'relation_service'])"; then
    echo "❌ QueryService not properly integrated with required services"
    echo "Please ensure QueryService has proper dependencies on GraphManager, EntityService, and RelationService"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate query builder features
function validate_query_builder() {
  cd knowledge/packages/graph-service

  # Check if query builder supports complex queries
  if ! python -c "from query_service.builder import QueryBuilder; assert all(hasattr(QueryBuilder, feature) for feature in ['filter', 'sort', 'aggregate', 'group_by', 'join'])"; then
    echo "❌ Query builder missing support for complex queries"
    echo "Please ensure QueryBuilder supports filtering, sorting, aggregation, grouping, and joins"
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

echo "Validating query builder features..."
validate_query_builder

echo "✅ QueryService implementation validated successfully!"
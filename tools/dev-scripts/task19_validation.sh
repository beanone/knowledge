#!/bin/bash
# tools/dev-scripts/task19_validation.sh
# Validates FileDB Connector implementation

set -e

# Ensure we're in the project root
cd "$(git rev-parse --show-toplevel)"

source .venv/bin/activate

# Validate directory structure
function validate_directory_structure() {
  cd knowledge/packages/graph-core

  # Check required directories
  required_dirs=(
    "src/backends/filedb"
    "tests/backends/filedb"
  )

  for dir in "${required_dirs[@]}"; do
    if [ ! -d "$dir" ]; then
      echo "❌ Missing required directory: $dir"
      echo "Please ensure your directory structure matches the one specified in tasks.md"
      exit 1
    fi
  done

  # Check required files
  required_files=(
    "src/backends/filedb/__init__.py"
    "src/backends/filedb/connector.py"
    "src/backends/filedb/storage.py"
    "src/backends/filedb/indexing.py"
    "src/backends/filedb/query.py"
    "src/backends/filedb/transaction.py"
    "src/backends/filedb/utils.py"
    "tests/backends/filedb/__init__.py"
    "tests/backends/filedb/test_crud.py"
    "tests/backends/filedb/test_persistence.py"
    "tests/backends/filedb/test_indexing.py"
    "tests/backends/filedb/test_query.py"
    "tests/backends/filedb/test_utils.py"
    "tests/backends/filedb/test_integration.py"
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

# Validate code quality
function validate_code_quality() {
  cd knowledge/packages/graph-core

  # Check type hints
  if ! mypy src/backends/filedb; then
    echo "❌ Type checking failed"
    echo "Please ensure all code has proper type annotations"
    exit 1
  fi

  # Validate code formatting
  if ! ruff check src/backends/filedb; then
    echo "❌ Code style validation failed"
    echo "Please run 'ruff check --fix src/backends/filedb' to fix formatting issues"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate test coverage
function validate_test_coverage() {
  cd knowledge/packages/graph-core

  # Run tests with coverage
  if ! pytest tests/backends/filedb \
      --cov=src/backends/filedb \
      --cov-report=term-missing \
      --cov-fail-under=95; then
    echo "❌ Tests failed or coverage below 95%"
    echo "Please ensure all tests pass and maintain at least 95% coverage"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate FileDB functionality
function validate_functionality() {
  cd knowledge/packages/graph-core

  # Test CRUD operations
  if ! pytest tests/backends/filedb/test_crud.py -v; then
    echo "❌ CRUD operation tests failed"
    echo "Please ensure basic CRUD operations work correctly with file storage"
    exit 1
  fi

  # Test persistence
  if ! pytest tests/backends/filedb/test_persistence.py -v; then
    echo "❌ Persistence tests failed"
    echo "Please ensure data is properly persisted and can be recovered"
    exit 1
  fi

  # Test indexing
  if ! pytest tests/backends/filedb/test_indexing.py -v; then
    echo "❌ Indexing tests failed"
    echo "Please ensure B-tree, hash, and full-text indexes work correctly"
    exit 1
  fi

  # Test query execution
  if ! pytest tests/backends/filedb/test_query.py -v; then
    echo "❌ Query execution tests failed"
    echo "Please ensure index-based lookups, sequential scans, and joins work correctly"
    exit 1
  fi

  # Test performance
  if ! pytest tests/backends/filedb/test_integration.py -v; then
    echo "❌ Performance tests failed"
    echo "Please ensure caching, batch operations, and parallel processing work correctly"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Run all validations
echo "Validating directory structure..."
validate_directory_structure

echo "Validating code quality..."
validate_code_quality

echo "Validating test coverage..."
validate_test_coverage

echo "Validating FileDB functionality..."
validate_functionality

echo "✅ FileDB Connector implementation validated successfully!"
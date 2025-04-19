#!/bin/bash
# tools/dev-scripts/task18_validation.sh
# Validates ArangoDB Connector implementation

set -e

# Ensure we're in the project root
cd "$(git rev-parse --show-toplevel)"

source .venv/bin/activate

# Validate directory structure
function validate_directory_structure() {
  cd knowledge/packages/graph-core

  # Check required directories
  required_dirs=(
    "src/backends/arango"
    "tests/backends/arango"
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
    "src/backends/arango/__init__.py"
    "src/backends/arango/connector.py"
    "src/backends/arango/queries.py"
    "src/backends/arango/transaction.py"
    "src/backends/arango/schema.py"
    "src/backends/arango/utils.py"
    "tests/backends/arango/__init__.py"
    "tests/backends/arango/test_connector.py"
    "tests/backends/arango/test_queries.py"
    "tests/backends/arango/test_transaction.py"
    "tests/backends/arango/test_schema.py"
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
  if ! mypy src/backends/arango; then
    echo "❌ Type checking failed"
    echo "Please ensure all code has proper type annotations"
    exit 1
  fi

  # Validate code formatting
  if ! ruff check src/backends/arango; then
    echo "❌ Code style validation failed"
    echo "Please run 'ruff check --fix src/backends/arango' to fix formatting issues"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate test coverage
function validate_test_coverage() {
  cd knowledge/packages/graph-core

  # Run tests with coverage
  if ! pytest tests/backends/arango \
      --cov=src/backends/arango \
      --cov-report=term-missing \
      --cov-fail-under=95; then
    echo "❌ Tests failed or coverage below 95%"
    echo "Please ensure all tests pass and maintain at least 95% coverage"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate ArangoDB integration
function validate_integration() {
  cd knowledge/packages/graph-core

  # Check ArangoDB container is running
  if ! docker ps | grep -q "arangodb"; then
    echo "❌ ArangoDB test container not running"
    echo "Please start the ArangoDB test container before running integration tests"
    exit 1
  fi

  # Run integration tests
  if ! pytest tests/backends/arango/test_connector.py -v; then
    echo "❌ ArangoDB integration tests failed"
    echo "Please ensure the connector works correctly with ArangoDB"
    exit 1
  fi

  # Test AQL query support
  if ! pytest tests/backends/arango/test_queries.py -v; then
    echo "❌ AQL query tests failed"
    echo "Please ensure native AQL query support is working"
    exit 1
  fi

  # Test transaction handling
  if ! pytest tests/backends/arango/test_transaction.py -v; then
    echo "❌ Transaction tests failed"
    echo "Please ensure proper transaction handling with optimistic locking"
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

echo "Validating ArangoDB integration..."
validate_integration

echo "✅ ArangoDB Connector implementation validated successfully!"
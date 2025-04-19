#!/bin/bash
# tools/dev-scripts/task4_validation.sh
# Validates Neo4j Backend implementation

set -e

# Ensure we're in the project root
cd "$(git rev-parse --show-toplevel)"

source .venv/bin/activate

# Validate directory structure
function validate_directory_structure() {
  cd knowledge/packages/graph-core

  # Check required directories exist
  required_dirs=(
    "src/backends"
    "src/backends/neo4j"
    "tests/backends"
    "tests/backends/neo4j"
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
    "src/backends/__init__.py"
    "src/backends/base.py"
    "src/backends/neo4j/__init__.py"
    "src/backends/neo4j/connector.py"
    "src/backends/neo4j/queries.py"
    "src/backends/neo4j/transaction.py"
    "src/backends/neo4j/utils.py"
    "tests/backends/__init__.py"
    "tests/backends/conftest.py"
    "tests/backends/neo4j/__init__.py"
    "tests/backends/neo4j/test_connector.py"
    "tests/backends/neo4j/test_queries.py"
    "tests/backends/neo4j/test_transaction.py"
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
  if ! mypy src/backends; then
    echo "❌ Type checking failed"
    echo "Please ensure all code has proper type annotations"
    exit 1
  fi

  # Validate code formatting
  if ! ruff check src/backends; then
    echo "❌ Code style validation failed"
    echo "Please run 'ruff check --fix src/backends' to fix formatting issues"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Run tests with coverage
function validate_tests() {
  cd knowledge/packages/graph-core

  # Run tests with coverage
  if ! pytest tests/backends \
      --cov=src/backends \
      --cov-report=term-missing \
      --cov-fail-under=95; then
    echo "❌ Tests failed or coverage below 95%"
    echo "Please ensure all tests pass and maintain at least 95% coverage"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate Neo4j integration
function validate_neo4j_integration() {
  cd knowledge/packages/graph-core

  # Check if Neo4j connector implements GraphContext interface
  if ! python -c "from graph_context.interface import GraphContext; from backends.neo4j.connector import Neo4jConnector; assert issubclass(Neo4jConnector, GraphContext)"; then
    echo "❌ Neo4j connector does not implement GraphContext interface"
    echo "Please ensure Neo4jConnector properly implements the GraphContext interface"
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

echo "Validating Neo4j integration..."
validate_neo4j_integration

echo "✅ Neo4j Backend implementation validated successfully!"
#!/bin/bash
# tools/dev-scripts/task5_validation.sh
# Validates GraphManager Service implementation

set -e

# Ensure we're in the project root
cd "$(git rev-parse --show-toplevel)"

source .venv/bin/activate

# Validate directory structure
function validate_directory_structure() {
  cd knowledge/packages/graph-service

  # Check required directories exist
  required_dirs=(
    "src/graph_manager"
    "tests/graph_manager"
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
    "src/graph_manager/__init__.py"
    "src/graph_manager/manager.py"
    "src/graph_manager/transaction.py"
    "src/graph_manager/operations.py"
    "src/graph_manager/errors.py"
    "src/graph_manager/utils.py"
    "tests/graph_manager/__init__.py"
    "tests/graph_manager/conftest.py"
    "tests/graph_manager/test_manager.py"
    "tests/graph_manager/test_transaction.py"
    "tests/graph_manager/test_operations.py"
    "tests/graph_manager/test_errors.py"
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
  if ! mypy src/graph_manager; then
    echo "❌ Type checking failed"
    echo "Please ensure all code has proper type annotations"
    exit 1
  fi

  # Validate code formatting
  if ! ruff check src/graph_manager; then
    echo "❌ Code style validation failed"
    echo "Please run 'ruff check --fix src/graph_manager' to fix formatting issues"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Run tests with coverage
function validate_tests() {
  cd knowledge/packages/graph-service

  # Run tests with coverage
  if ! pytest tests/graph_manager \
      --cov=src/graph_manager \
      --cov-report=term-missing \
      --cov-fail-under=90; then
    echo "❌ Tests failed or coverage below 90%"
    echo "Please ensure all tests pass and maintain at least 90% coverage"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate transaction management
function validate_transaction_management() {
  cd knowledge/packages/graph-service

  # Check if transaction management is properly implemented
  if ! python -c "from graph_manager.transaction import TransactionManager; assert hasattr(TransactionManager, 'begin') and hasattr(TransactionManager, 'commit') and hasattr(TransactionManager, 'rollback')"; then
    echo "❌ Transaction management not properly implemented"
    echo "Please ensure TransactionManager has begin(), commit(), and rollback() methods"
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

echo "Validating transaction management..."
validate_transaction_management

echo "✅ GraphManager Service implementation validated successfully!"
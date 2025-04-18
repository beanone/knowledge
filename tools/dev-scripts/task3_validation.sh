#!/bin/bash
# tools/dev-scripts/task3_validation.sh
# Validates Type System implementation

set -e

# Ensure we're in the project root
cd "$(git rev-parse --show-toplevel)"

source .venv/bin/activate

# Validate type system implementation
function validate_type_system() {
  cd knowledge/packages/graph-core

  # Check required type system components
  required_files=(
    "src/types/base.py"
    "src/types/validators.py"
    "src/types/schema.py"
    "src/types/properties.py"
  )

  for file in "${required_files[@]}"; do
    if [ ! -f "$file" ]; then
      echo "❌ Missing required file: $file"
      exit 1
    fi
  done

  # Validate type checking
  if ! mypy src/types; then
    echo "❌ Type checking failed"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Run tests with coverage
function validate_tests() {
  cd knowledge/packages/graph-core

  # Run type system tests
  if ! pytest tests/types \
      --cov=src/types \
      --cov-report=term-missing \
      --cov-fail-under=95; then
    echo "❌ Tests failed or coverage below 95%"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate schema validation capabilities
function validate_schema_validation() {
  cd knowledge/packages/graph-core

  # Test basic schema validation
  python3 -c "
  from knowledge.packages.graph_core.src.types import validate_schema
  test_schema = {
    'name': 'Person',
    'properties': {'name': 'string', 'age': 'integer'}
  }
  assert validate_schema(test_schema)
  "
  if [ $? -ne 0 ]; then
    echo "❌ Schema validation test failed"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Run all validations
validate_type_system
validate_tests
validate_schema_validation

echo "✅ Type system implementation validated"
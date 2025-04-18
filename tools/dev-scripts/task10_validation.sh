#!/bin/bash
# tools/dev-scripts/task10_validation.sh
# Validates Schema API implementation

set -e

# Ensure we're in the project root
cd "$(git rev-parse --show-toplevel)"

source .venv/bin/activate

# Validate API implementation
function validate_api() {
  cd knowledge/packages/graph-api

  # Check required API files
  required_files=(
    "src/routes/schema.py"
    "src/schemas/type_definitions.py"
    "src/services/schema_validator.py"
    "src/services/schema_manager.py"
  )

  for file in "${required_files[@]}"; do
    if [ ! -f "$file" ]; then
      echo "❌ Missing required file: $file"
      exit 1
    fi
  done

  # Validate type checking
  if ! mypy src/routes/schema.py src/schemas/type_definitions.py \
          src/services/schema_validator.py src/services/schema_manager.py; then
    echo "❌ Type checking failed"
    exit 1
  fi

  # Validate code style
  if ! ruff check src/routes/schema.py src/schemas/type_definitions.py \
          src/services/schema_validator.py src/services/schema_manager.py; then
    echo "❌ Code style validation failed"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate type definition endpoints
function validate_type_endpoints() {
  cd knowledge/packages/graph-api

  # Run type definition endpoint tests
  if ! pytest tests/routes/test_schema_types.py \
      --cov=src/routes/schema.py \
      --cov-report=term-missing \
      --cov-fail-under=90; then
    echo "❌ Type definition endpoint tests failed or coverage below 90%"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate schema management
function validate_schema_management() {
  cd knowledge/packages/graph-api

  # Run schema management tests
  if ! pytest tests/services/test_schema_manager.py \
      --cov=src/services/schema_manager.py \
      --cov-report=term-missing \
      --cov-fail-under=90; then
    echo "❌ Schema management tests failed or coverage below 90%"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate schema validation
function validate_schema_validation() {
  cd knowledge/packages/graph-api

  # Run schema validation tests
  if ! pytest tests/services/test_schema_validator.py \
      --cov=src/services/schema_validator.py \
      --cov-report=term-missing \
      --cov-fail-under=90; then
    echo "❌ Schema validation tests failed or coverage below 90%"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Run all validations
validate_api
validate_type_endpoints
validate_schema_management
validate_schema_validation

echo "✅ Schema API implementation validated"
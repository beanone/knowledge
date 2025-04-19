#!/bin/bash
# tools/dev-scripts/task10_validation.sh
# Validates Schema API implementation

set -e

# Ensure we're in the project root
cd "$(git rev-parse --show-toplevel)"

source .venv/bin/activate

# Validate directory structure
function validate_directory_structure() {
  cd knowledge/packages/graph-api

  # Check required directories
  required_dirs=(
    "src/routes"
    "src/schemas"
    "src/services"
    "tests/routes"
    "tests/services"
  )

  for dir in "${required_dirs[@]}"; do
    if [ ! -d "$dir" ]; then
      echo "❌ Missing required directory: $dir"
      exit 1
    fi
  done

  # Check required files
  required_files=(
    "src/routes/__init__.py"
    "src/routes/schema.py"
    "src/schemas/__init__.py"
    "src/schemas/type_definitions.py"
    "src/services/__init__.py"
    "src/services/schema_validator.py"
    "src/services/schema_manager.py"
    "src/__init__.py"
    "tests/routes/__init__.py"
    "tests/routes/test_schema_types.py"
    "tests/services/__init__.py"
    "tests/services/test_schema_validator.py"
    "tests/services/test_schema_manager.py"
  )

  for file in "${required_files[@]}"; do
    if [ ! -f "$file" ]; then
      echo "❌ Missing required file: $file"
      exit 1
    fi
  done

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate API implementation
function validate_api() {
  cd knowledge/packages/graph-api

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

  # Validate OpenAPI documentation
  if ! python -c "from fastapi.openapi.utils import get_openapi; from src.main import app; spec = get_openapi(title=app.title, version=app.version, routes=app.routes); assert any('/schema' in path for path in spec['paths'])"; then
    echo "❌ OpenAPI documentation validation failed"
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

  # Validate GraphManager integration
  if ! python -c "from src.services.schema_manager import SchemaManager; from src.services.graph_manager import GraphManager; assert issubclass(SchemaManager, GraphManager)"; then
    echo "❌ Schema manager is not properly integrated with GraphManager"
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
echo "Validating directory structure..."
validate_directory_structure

echo "Validating API implementation..."
validate_api

echo "Validating type definition endpoints..."
validate_type_endpoints

echo "Validating schema management..."
validate_schema_management

echo "Validating schema validation..."
validate_schema_validation

echo "✅ Schema API implementation validated"
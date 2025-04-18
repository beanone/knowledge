#!/bin/bash
# tools/dev-scripts/task9_validation.sh
# Validates REST API Core implementation

set -e

# Ensure we're in the project root
cd "$(git rev-parse --show-toplevel)"

source .venv/bin/activate

# Validate API implementation
function validate_api() {
  cd knowledge/packages/graph-api

  # Check required API files
  required_files=(
    "src/app.py"
    "src/routes/crud.py"
    "src/middleware/error_handler.py"
    "src/schemas/base.py"
  )

  for file in "${required_files[@]}"; do
    if [ ! -f "$file" ]; then
      echo "❌ Missing required file: $file"
      exit 1
    fi
  done

  # Validate type checking
  if ! mypy src/; then
    echo "❌ Type checking failed"
    exit 1
  fi

  # Validate code style
  if ! ruff check src/; then
    echo "❌ Code style validation failed"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate FastAPI setup
function validate_fastapi_setup() {
  cd knowledge/packages/graph-api

  # Run FastAPI setup tests
  if ! pytest tests/test_app.py \
      --cov=src/app.py \
      --cov-report=term-missing \
      --cov-fail-under=90; then
    echo "❌ FastAPI setup tests failed or coverage below 90%"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate CRUD endpoints
function validate_crud_endpoints() {
  cd knowledge/packages/graph-api

  # Run CRUD endpoint tests
  if ! pytest tests/routes/test_crud.py \
      --cov=src/routes/crud.py \
      --cov-report=term-missing \
      --cov-fail-under=90; then
    echo "❌ CRUD endpoint tests failed or coverage below 90%"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate error handling
function validate_error_handling() {
  cd knowledge/packages/graph-api

  # Run error handling tests
  if ! pytest tests/middleware/test_error_handler.py \
      --cov=src/middleware/error_handler.py \
      --cov-report=term-missing \
      --cov-fail-under=90; then
    echo "❌ Error handling tests failed or coverage below 90%"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate API documentation
function validate_api_docs() {
  cd knowledge/packages/graph-api

  # Check OpenAPI schema generation
  if ! python -c "
    from src.app import app
    assert app.openapi() is not None
    "; then
    echo "❌ OpenAPI schema validation failed"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Run all validations
validate_api
validate_fastapi_setup
validate_crud_endpoints
validate_error_handling
validate_api_docs

echo "✅ REST API Core implementation validated"
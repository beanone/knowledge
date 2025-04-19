#!/bin/bash
# tools/dev-scripts/task9_validation.sh
# Validates REST API Core implementation

set -e

# Ensure we're in the project root
cd "$(git rev-parse --show-toplevel)"

source .venv/bin/activate

# Validate directory structure
function validate_directory_structure() {
  cd knowledge/packages/graph-api

  # Check required directories exist
  required_dirs=(
    "src/api"
    "src/api/routes"
    "src/api/models"
    "src/api/middleware"
    "src/api/utils"
    "tests/api"
    "tests/api/routes"
    "tests/api/models"
    "tests/api/middleware"
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
    "src/api/__init__.py"
    "src/api/app.py"
    "src/api/routes/__init__.py"
    "src/api/routes/entities.py"
    "src/api/routes/relations.py"
    "src/api/routes/common.py"
    "src/api/models/__init__.py"
    "src/api/models/entities.py"
    "src/api/models/relations.py"
    "src/api/models/common.py"
    "src/api/middleware/__init__.py"
    "src/api/middleware/auth.py"
    "src/api/middleware/error.py"
    "src/api/utils/__init__.py"
    "src/api/utils/responses.py"
    "src/api/utils/validation.py"
    "tests/api/__init__.py"
    "tests/api/conftest.py"
    "tests/api/test_app.py"
    "tests/api/routes/test_entities.py"
    "tests/api/routes/test_relations.py"
    "tests/api/routes/test_common.py"
    "tests/api/models/test_entities.py"
    "tests/api/models/test_relations.py"
    "tests/api/models/test_common.py"
    "tests/api/middleware/test_auth.py"
    "tests/api/middleware/test_error.py"
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
  cd knowledge/packages/graph-api

  # Check type hints
  if ! mypy src/api; then
    echo "❌ Type checking failed"
    echo "Please ensure all code has proper type annotations"
    exit 1
  fi

  # Validate code formatting
  if ! ruff check src/api; then
    echo "❌ Code style validation failed"
    echo "Please run 'ruff check --fix src/api' to fix formatting issues"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Run tests with coverage
function validate_tests() {
  cd knowledge/packages/graph-api

  # Run tests with coverage
  if ! pytest tests/api \
      --cov=src/api \
      --cov-report=term-missing \
      --cov-fail-under=90; then
    echo "❌ Tests failed or coverage below 90%"
    echo "Please ensure all tests pass and maintain at least 90% coverage"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate FastAPI application
function validate_fastapi_app() {
  cd knowledge/packages/graph-api

  # Check FastAPI app configuration
  if ! python -c "from api.app import app; from fastapi import FastAPI; assert isinstance(app, FastAPI); assert app.middleware"; then
    echo "❌ FastAPI application not properly configured"
    echo "Please ensure FastAPI app is properly set up with middleware"
    exit 1
  fi

  # Check OpenAPI documentation
  if ! python -c "from api.app import app; assert app.openapi() is not None"; then
    echo "❌ OpenAPI documentation not generated"
    echo "Please ensure OpenAPI documentation is properly configured"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate service integration
function validate_service_integration() {
  cd knowledge/packages/graph-api

  # Check if API properly integrates with required services
  if ! python -c "from api.app import app; assert all(dep in app.dependency_overrides for dep in ['graph_manager', 'entity_service', 'relation_service', 'query_service'])"; then
    echo "❌ API not properly integrated with required services"
    echo "Please ensure API has proper dependencies on GraphManager, EntityService, RelationService, and QueryService"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate CRUD endpoints
function validate_crud_endpoints() {
  cd knowledge/packages/graph-api

  # Start test server
  python -c "from api.app import app; import uvicorn; import threading; threading.Thread(target=uvicorn.run, args=(app,), kwargs={'host': 'localhost', 'port': 8000}, daemon=True).start()" &
  sleep 5

  # Test endpoints
  if ! curl -s http://localhost:8000/docs > /dev/null; then
    echo "❌ API documentation endpoint not accessible"
    exit 1
  fi

  # Check CRUD endpoints exist
  endpoints=(
    "/api/v1/entities"
    "/api/v1/relations"
  )

  for endpoint in "${endpoints[@]}"; do
    if ! curl -s "http://localhost:8000$endpoint" -I | grep -q "HTTP/1.1 \(200\|401\|403\)"; then
      echo "❌ Endpoint $endpoint not properly implemented"
      exit 1
    fi
  done

  # Kill test server
  pkill -f "uvicorn.*:app"

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

echo "Validating FastAPI application..."
validate_fastapi_app

echo "Validating service integration..."
validate_service_integration

echo "Validating CRUD endpoints..."
validate_crud_endpoints

echo "✅ REST API Core implementation validated successfully!"
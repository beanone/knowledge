#!/bin/bash
# tools/dev-scripts/task7_validation.sh
# Validates RelationService implementation

set -e

# Ensure we're in the project root
cd "$(git rev-parse --show-toplevel)"

source .venv/bin/activate

# Validate service implementation
function validate_service() {
  cd knowledge/packages/graph-service

  # Check required service files
  required_files=(
    "src/services/relation_service.py"
    "src/services/endpoint_manager.py"
    "src/services/metadata_handler.py"
  )

  for file in "${required_files[@]}"; do
    if [ ! -f "$file" ]; then
      echo "❌ Missing required file: $file"
      exit 1
    fi
  done

  # Validate type checking
  if ! mypy src/services/relation_service.py src/services/endpoint_manager.py src/services/metadata_handler.py; then
    echo "❌ Type checking failed"
    exit 1
  fi

  # Validate code style
  if ! ruff check src/services/relation_service.py src/services/endpoint_manager.py src/services/metadata_handler.py; then
    echo "❌ Code style validation failed"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate relationship management
function validate_relationship_management() {
  cd knowledge/packages/graph-service

  # Run relationship management tests
  if ! pytest tests/services/test_relation_service.py \
      --cov=src/services/relation_service.py \
      --cov-report=term-missing \
      --cov-fail-under=90; then
    echo "❌ Relationship management tests failed or coverage below 90%"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate endpoint handling
function validate_endpoint_handling() {
  cd knowledge/packages/graph-service

  # Run endpoint handling tests
  if ! pytest tests/services/test_endpoint_manager.py \
      --cov=src/services/endpoint_manager.py \
      --cov-report=term-missing \
      --cov-fail-under=90; then
    echo "❌ Endpoint handling tests failed or coverage below 90%"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate metadata management
function validate_metadata_management() {
  cd knowledge/packages/graph-service

  # Run metadata management tests
  if ! pytest tests/services/test_metadata_handler.py \
      --cov=src/services/metadata_handler.py \
      --cov-report=term-missing \
      --cov-fail-under=90; then
    echo "❌ Metadata management tests failed or coverage below 90%"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Run all validations
validate_service
validate_relationship_management
validate_endpoint_handling
validate_metadata_management

echo "✅ RelationService implementation validated"
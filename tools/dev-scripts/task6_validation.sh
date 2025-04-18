#!/bin/bash
# tools/dev-scripts/task6_validation.sh
# Validates EntityService implementation

set -e

# Ensure we're in the project root
cd "$(git rev-parse --show-toplevel)"

source .venv/bin/activate

# Validate service implementation
function validate_service() {
  cd knowledge/packages/graph-service

  # Check required service files
  required_files=(
    "src/services/entity_service.py"
    "src/services/property_manager.py"
    "src/services/validators.py"
  )

  for file in "${required_files[@]}"; do
    if [ ! -f "$file" ]; then
      echo "❌ Missing required file: $file"
      exit 1
    fi
  done

  # Validate type checking
  if ! mypy src/services/entity_service.py src/services/property_manager.py src/services/validators.py; then
    echo "❌ Type checking failed"
    exit 1
  fi

  # Validate code style
  if ! ruff check src/services/entity_service.py src/services/property_manager.py src/services/validators.py; then
    echo "❌ Code style validation failed"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate entity workflows
function validate_workflows() {
  cd knowledge/packages/graph-service

  # Run workflow-specific tests
  if ! pytest tests/services/test_entity_workflows.py \
      --cov=src/services/entity_service.py \
      --cov-report=term-missing \
      --cov-fail-under=90; then
    echo "❌ Workflow tests failed or coverage below 90%"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate property management
function validate_property_management() {
  cd knowledge/packages/graph-service

  # Run property management tests
  if ! pytest tests/services/test_property_manager.py \
      --cov=src/services/property_manager.py \
      --cov-report=term-missing \
      --cov-fail-under=90; then
    echo "❌ Property management tests failed or coverage below 90%"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate validation logic
function validate_validation_logic() {
  cd knowledge/packages/graph-service

  # Run validation logic tests
  if ! pytest tests/services/test_validators.py \
      --cov=src/services/validators.py \
      --cov-report=term-missing \
      --cov-fail-under=90; then
    echo "❌ Validation logic tests failed or coverage below 90%"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Run all validations
validate_service
validate_workflows
validate_property_management
validate_validation_logic

echo "✅ EntityService implementation validated"
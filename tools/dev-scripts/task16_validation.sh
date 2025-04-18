#!/bin/bash
# tools/dev-scripts/task16_validation.sh
# Validates Schema Editor UI implementation

set -e

# Ensure we're in the project root
cd "$(git rev-parse --show-toplevel)"

source .venv/bin/activate

# Validate implementation
function validate_implementation() {
  cd knowledge/packages/graph-ui

  # Check required files
  required_files=(
    "src/components/schema/TypeManager.tsx"
    "src/components/schema/PropertyEditor.tsx"
    "src/components/schema/ValidationRules.tsx"
    "src/components/schema/SchemaViewer.tsx"
    "src/hooks/useSchemaData.ts"
    "src/hooks/useSchemaValidation.ts"
    "src/styles/schema-editor.css"
  )

  for file in "${required_files[@]}"; do
    if [ ! -f "$file" ]; then
      echo "❌ Missing required file: $file"
      exit 1
    fi
  done

  # Validate TypeScript compilation
  if ! tsc --noEmit; then
    echo "❌ TypeScript compilation failed"
    exit 1
  fi

  # Validate code style
  if ! eslint src/components/schema/; then
    echo "❌ Code style validation failed"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate type management
function validate_type_management() {
  cd knowledge/packages/graph-ui

  # Run type management tests
  if ! jest src/components/schema/__tests__/TypeManager.test.tsx \
      --coverage \
      --coverageThreshold='{"global":{"lines":90}}'; then
    echo "❌ Type management tests failed or coverage below 90%"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate property editor
function validate_property_editor() {
  cd knowledge/packages/graph-ui

  # Run property editor tests
  if ! jest src/components/schema/__tests__/PropertyEditor.test.tsx \
      --coverage \
      --coverageThreshold='{"global":{"lines":90}}'; then
    echo "❌ Property editor tests failed or coverage below 90%"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate validation rules
function validate_validation_rules() {
  cd knowledge/packages/graph-ui

  # Run validation rules tests
  if ! jest src/components/schema/__tests__/ValidationRules.test.tsx \
      --coverage \
      --coverageThreshold='{"global":{"lines":90}}'; then
    echo "❌ Validation rules tests failed or coverage below 90%"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate real-time validation
function validate_realtime_validation() {
  cd knowledge/packages/graph-ui

  # Run real-time validation tests
  if ! jest src/hooks/__tests__/useSchemaValidation.test.ts \
      --coverage \
      --coverageThreshold='{"global":{"lines":90}}'; then
    echo "❌ Real-time validation tests failed or coverage below 90%"
    exit 1
  fi

  # Test validation response time
  if ! jest src/components/schema/__tests__/performance.test.tsx; then
    echo "❌ Validation performance tests failed"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Run all validations
validate_implementation
validate_type_management
validate_property_editor
validate_validation_rules
validate_realtime_validation

echo "✅ Schema Editor UI implementation validated"
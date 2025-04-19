#!/bin/bash
# tools/dev-scripts/task16_validation.sh
# Validates Schema Editor UI implementation

set -e

# Ensure we're in the project root
cd "$(git rev-parse --show-toplevel)"

source .venv/bin/activate

# Validate directory structure
function validate_directory_structure() {
  cd knowledge/packages/graph-ui

  # Check required directories
  required_dirs=(
    "src/components/schema"
    "src/hooks"
    "src/services"
    "src/styles"
    "src/utils"
    "tests/components/schema/__tests__"
    "tests/components/schema/__mocks__"
  )

  for dir in "${required_dirs[@]}"; do
    if [ ! -d "$dir" ]; then
      echo "❌ Missing required directory: $dir"
      echo "Please ensure your directory structure matches the one specified in tasks.md"
      exit 1
    fi
  done

  # Check required files
  required_files=(
    "src/components/schema/TypeEditor.tsx"
    "src/components/schema/PropertyEditor.tsx"
    "src/components/schema/ValidationEditor.tsx"
    "src/components/schema/SchemaViewer.tsx"
    "src/components/schema/types.ts"
    "src/hooks/useSchemaData.ts"
    "src/hooks/useValidation.ts"
    "src/services/schemaApi.ts"
    "src/services/validationEngine.ts"
    "src/styles/schema.css"
    "src/utils/schemaTransforms.ts"
    "src/utils/validation.ts"
    "tests/components/schema/__tests__/TypeEditor.test.tsx"
    "tests/components/schema/__tests__/PropertyEditor.test.tsx"
    "tests/components/schema/__tests__/ValidationEditor.test.tsx"
    "tests/components/schema/__tests__/SchemaViewer.test.tsx"
    "tests/components/schema/__tests__/integration.test.tsx"
    "tests/components/schema/__mocks__/schemaData.ts"
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

# Validate code quality
function validate_code_quality() {
  cd knowledge/packages/graph-ui

  # Validate TypeScript compilation
  if ! tsc --noEmit; then
    echo "❌ TypeScript compilation failed"
    echo "Please fix type errors before proceeding"
    exit 1
  fi

  # Validate code style
  if ! eslint 'src/components/schema/**/*.{ts,tsx}' 'src/hooks/**/*.ts'; then
    echo "❌ Code style validation failed"
    echo "Please run 'eslint --fix' to attempt automatic fixes"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate test coverage
function validate_test_coverage() {
  cd knowledge/packages/graph-ui

  # Run all component tests with coverage
  if ! jest 'src/components/schema/__tests__/*.test.tsx' \
      --coverage \
      --coverageThreshold='{"global":{"lines":90,"statements":90,"functions":90,"branches":90}}'; then
    echo "❌ Tests failed or coverage below 90%"
    echo "Please ensure all tests pass and maintain at least 90% coverage"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate schema editor functionality
function validate_functionality() {
  cd knowledge/packages/graph-ui

  # Validate type management
  if ! jest src/components/schema/__tests__/TypeEditor.test.tsx; then
    echo "❌ Type management tests failed"
    echo "Please ensure type creation, editing, inheritance, and documentation features work correctly"
    exit 1
  fi

  # Validate property editor
  if ! jest src/components/schema/__tests__/PropertyEditor.test.tsx; then
    echo "❌ Property editor tests failed"
    echo "Please ensure property type selection, configuration, and constraints work correctly"
    exit 1
  fi

  # Validate validation rules
  if ! jest src/components/schema/__tests__/ValidationEditor.test.tsx; then
    echo "❌ Validation rules tests failed"
    echo "Please ensure rule creation, dependency management, and preview features work correctly"
    exit 1
  fi

  # Validate integration
  if ! jest src/components/schema/__tests__/integration.test.tsx; then
    echo "❌ Integration tests failed"
    echo "Please ensure all components work together correctly"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Run all validations
echo "Validating directory structure..."
validate_directory_structure

echo "Validating code quality..."
validate_code_quality

echo "Validating test coverage..."
validate_test_coverage

echo "Validating schema editor functionality..."
validate_functionality

echo "✅ Schema Editor UI implementation validated successfully!"
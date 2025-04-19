#!/bin/bash
# tools/dev-scripts/task17_validation.sh
# Validates Query Builder UI implementation

set -e

# Ensure we're in the project root
cd "$(git rev-parse --show-toplevel)"

source .venv/bin/activate

# Validate directory structure
function validate_directory_structure() {
  cd knowledge/packages/graph-ui

  # Check required directories
  required_dirs=(
    "src/components/query"
    "src/hooks"
    "src/services"
    "src/styles"
    "src/utils"
    "tests/components/query/__tests__"
    "tests/components/query/__mocks__"
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
    "src/components/query/QueryBuilder.tsx"
    "src/components/query/PatternEditor.tsx"
    "src/components/query/ResultViewer.tsx"
    "src/components/query/QueryHistory.tsx"
    "src/components/query/types.ts"
    "src/hooks/useQueryBuilder.ts"
    "src/hooks/useQueryExecution.ts"
    "src/hooks/useQueryHistory.ts"
    "src/services/queryApi.ts"
    "src/services/queryValidator.ts"
    "src/services/resultFormatter.ts"
    "src/styles/query.css"
    "src/utils/queryTransforms.ts"
    "src/utils/visualization.ts"
    "tests/components/query/__tests__/QueryBuilder.test.tsx"
    "tests/components/query/__tests__/PatternEditor.test.tsx"
    "tests/components/query/__tests__/ResultViewer.test.tsx"
    "tests/components/query/__tests__/QueryHistory.test.tsx"
    "tests/components/query/__tests__/integration.test.tsx"
    "tests/components/query/__mocks__/queryData.ts"
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
  if ! eslint 'src/components/query/**/*.{ts,tsx}' 'src/hooks/**/*.ts'; then
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
  if ! jest 'src/components/query/__tests__/*.test.tsx' \
      --coverage \
      --coverageThreshold='{"global":{"lines":90,"statements":90,"functions":90,"branches":90}}'; then
    echo "❌ Tests failed or coverage below 90%"
    echo "Please ensure all tests pass and maintain at least 90% coverage"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate query builder functionality
function validate_functionality() {
  cd knowledge/packages/graph-ui

  # Validate query builder
  if ! jest src/components/query/__tests__/QueryBuilder.test.tsx; then
    echo "❌ Query builder tests failed"
    echo "Please ensure drag-and-drop pattern building, parameter configuration, and template management work correctly"
    exit 1
  fi

  # Validate pattern editor
  if ! jest src/components/query/__tests__/PatternEditor.test.tsx; then
    echo "❌ Pattern editor tests failed"
    echo "Please ensure node patterns, edge patterns, property constraints, and path expressions work correctly"
    exit 1
  fi

  # Validate result viewer
  if ! jest src/components/query/__tests__/ResultViewer.test.tsx; then
    echo "❌ Result viewer tests failed"
    echo "Please ensure visualization modes, filtering, sorting, and export capabilities work correctly"
    exit 1
  fi

  # Validate query history
  if ! jest src/components/query/__tests__/QueryHistory.test.tsx; then
    echo "❌ Query history tests failed"
    echo "Please ensure history tracking, reuse, and management features work correctly"
    exit 1
  fi

  # Validate integration
  if ! jest src/components/query/__tests__/integration.test.tsx; then
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

echo "Validating query builder functionality..."
validate_functionality

echo "✅ Query Builder UI implementation validated successfully!"
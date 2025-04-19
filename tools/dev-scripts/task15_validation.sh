#!/bin/bash
# tools/dev-scripts/task15_validation.sh
# Validates Graph Explorer UI implementation

set -e

# Ensure we're in the project root
cd "$(git rev-parse --show-toplevel)"

source .venv/bin/activate

# Validate directory structure
function validate_directory_structure() {
  cd knowledge/packages/graph-ui

  # Check required directories
  required_dirs=(
    "src/components/explorer"
    "src/hooks"
    "src/services"
    "src/styles"
    "src/utils"
    "tests/components/explorer/__tests__"
    "tests/components/explorer/__mocks__"
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
    "src/components/explorer/GraphViewer.tsx"
    "src/components/explorer/NavigationControls.tsx"
    "src/components/explorer/SearchPanel.tsx"
    "src/components/explorer/FilterPanel.tsx"
    "src/components/explorer/types.ts"
    "src/hooks/useGraphData.ts"
    "src/hooks/useGraphLayout.ts"
    "src/services/graphApi.ts"
    "src/services/layoutEngine.ts"
    "src/styles/explorer.css"
    "src/utils/graphTransforms.ts"
    "src/utils/visualization.ts"
    "tests/components/explorer/__tests__/GraphViewer.test.tsx"
    "tests/components/explorer/__tests__/NavigationControls.test.tsx"
    "tests/components/explorer/__tests__/SearchPanel.test.tsx"
    "tests/components/explorer/__tests__/FilterPanel.test.tsx"
    "tests/components/explorer/__tests__/performance.test.tsx"
    "tests/components/explorer/__mocks__/graphData.ts"
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
  if ! eslint 'src/components/explorer/**/*.{ts,tsx}' 'src/hooks/**/*.ts'; then
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
  if ! jest 'src/components/explorer/__tests__/*.test.tsx' \
      --coverage \
      --coverageThreshold='{"global":{"lines":90,"statements":90,"functions":90,"branches":90}}'; then
    echo "❌ Tests failed or coverage below 90%"
    echo "Please ensure all tests pass and maintain at least 90% coverage"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate performance requirements
function validate_performance() {
  cd knowledge/packages/graph-ui

  # Run performance tests
  if ! jest src/components/explorer/__tests__/performance.test.tsx; then
    echo "❌ Performance tests failed"
    echo "Please ensure the UI can handle 1000+ nodes without lag"
    exit 1
  fi

  # Check bundle size
  if ! yarn build && [ $(stat -f%z dist/main.js) -gt 500000 ]; then
    echo "❌ Bundle size exceeds 500KB limit"
    echo "Please optimize your bundle size through code splitting or other techniques"
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

echo "Validating performance requirements..."
validate_performance

echo "✅ Graph Explorer UI implementation validated successfully!"
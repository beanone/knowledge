#!/bin/bash
# tools/dev-scripts/task15_validation.sh
# Validates Graph Explorer UI implementation

set -e

# Ensure we're in the project root
cd "$(git rev-parse --show-toplevel)"

source .venv/bin/activate

# Validate implementation
function validate_implementation() {
  cd knowledge/packages/graph-ui

  # Check required files
  required_files=(
    "src/components/explorer/GraphViewer.tsx"
    "src/components/explorer/NavigationControls.tsx"
    "src/components/explorer/SearchPanel.tsx"
    "src/components/explorer/FilterPanel.tsx"
    "src/hooks/useGraphData.ts"
    "src/hooks/useGraphLayout.ts"
    "src/styles/explorer.css"
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
  if ! eslint src/components/explorer/; then
    echo "❌ Code style validation failed"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate visualization components
function validate_visualization() {
  cd knowledge/packages/graph-ui

  # Run visualization tests
  if ! jest src/components/explorer/__tests__/GraphViewer.test.tsx \
      --coverage \
      --coverageThreshold='{"global":{"lines":90}}'; then
    echo "❌ Visualization tests failed or coverage below 90%"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate navigation system
function validate_navigation() {
  cd knowledge/packages/graph-ui

  # Run navigation tests
  if ! jest src/components/explorer/__tests__/NavigationControls.test.tsx \
      --coverage \
      --coverageThreshold='{"global":{"lines":90}}'; then
    echo "❌ Navigation tests failed or coverage below 90%"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate search and filter
function validate_search_filter() {
  cd knowledge/packages/graph-ui

  # Run search and filter tests
  if ! jest 'src/components/explorer/__tests__/(SearchPanel|FilterPanel).test.tsx' \
      --coverage \
      --coverageThreshold='{"global":{"lines":90}}'; then
    echo "❌ Search and filter tests failed or coverage below 90%"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate performance
function validate_performance() {
  cd knowledge/packages/graph-ui

  # Run performance tests
  if ! jest src/components/explorer/__tests__/performance.test.tsx; then
    echo "❌ Performance tests failed"
    exit 1
  fi

  # Check bundle size
  if ! yarn build && [ $(stat -f%z dist/main.js) -gt 500000 ]; then
    echo "❌ Bundle size exceeds 500KB limit"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Run all validations
validate_implementation
validate_visualization
validate_navigation
validate_search_filter
validate_performance

echo "✅ Graph Explorer UI implementation validated"
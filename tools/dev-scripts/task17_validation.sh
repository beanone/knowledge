#!/bin/bash
# tools/dev-scripts/task17_validation.sh
# Validates Query Builder UI implementation

set -e

# Ensure we're in the project root
cd "$(git rev-parse --show-toplevel)"

source .venv/bin/activate

# Validate implementation
function validate_implementation() {
  cd knowledge/packages/graph-ui

  # Check required files
  required_files=(
    "src/components/query/QueryBuilder.tsx"
    "src/components/query/PatternEditor.tsx"
    "src/components/query/ResultViewer.tsx"
    "src/components/query/QueryValidator.tsx"
    "src/hooks/useQueryBuilder.ts"
    "src/hooks/useQueryValidation.ts"
    "src/hooks/useQueryResults.ts"
    "src/styles/query-builder.css"
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
  if ! eslint src/components/query/; then
    echo "❌ Code style validation failed"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate visual query interface
function validate_visual_interface() {
  cd knowledge/packages/graph-ui

  # Run visual interface tests
  if ! jest src/components/query/__tests__/QueryBuilder.test.tsx \
      --coverage \
      --coverageThreshold='{"global":{"lines":90}}'; then
    echo "❌ Visual interface tests failed or coverage below 90%"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate pattern matching
function validate_pattern_matching() {
  cd knowledge/packages/graph-ui

  # Run pattern matching tests
  if ! jest src/components/query/__tests__/PatternEditor.test.tsx \
      --coverage \
      --coverageThreshold='{"global":{"lines":90}}'; then
    echo "❌ Pattern matching tests failed or coverage below 90%"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate result visualization
function validate_result_visualization() {
  cd knowledge/packages/graph-ui

  # Run result visualization tests
  if ! jest src/components/query/__tests__/ResultViewer.test.tsx \
      --coverage \
      --coverageThreshold='{"global":{"lines":90}}'; then
    echo "❌ Result visualization tests failed or coverage below 90%"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate query validation
function validate_query_validation() {
  cd knowledge/packages/graph-ui

  # Run query validation tests
  if ! jest src/components/query/__tests__/QueryValidator.test.tsx \
      --coverage \
      --coverageThreshold='{"global":{"lines":90}}'; then
    echo "❌ Query validation tests failed or coverage below 90%"
    exit 1
  fi

  # Test error handling
  if ! jest src/hooks/__tests__/useQueryValidation.test.ts; then
    echo "❌ Query validation error handling tests failed"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Run all validations
validate_implementation
validate_visual_interface
validate_pattern_matching
validate_result_visualization
validate_query_validation

echo "✅ Query Builder UI implementation validated"
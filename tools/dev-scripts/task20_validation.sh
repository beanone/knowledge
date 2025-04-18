#!/bin/bash
# tools/dev-scripts/task20_validation.sh
# Validates Comprehensive Testing implementation

set -e

# Ensure we're in the project root
cd "$(git rev-parse --show-toplevel)"

source .venv/bin/activate

# Validate unit tests
function validate_unit_tests() {
  # Test core package
  cd knowledge/packages/graph-core
  if ! pytest tests/unit/ \
      --cov=src \
      --cov-report=term-missing \
      --cov-fail-under=95; then
    echo "❌ Core package unit tests failed or coverage below 95%"
    exit 1
  fi
  cd "$(git rev-parse --show-toplevel)"

  # Test API package
  cd knowledge/packages/graph-api
  if ! pytest tests/unit/ \
      --cov=src \
      --cov-report=term-missing \
      --cov-fail-under=95; then
    echo "❌ API package unit tests failed or coverage below 95%"
    exit 1
  fi
  cd "$(git rev-parse --show-toplevel)"

  # Test UI package
  cd knowledge/packages/graph-ui
  if ! jest --coverage --coverageThreshold='{"global":{"lines":95}}' \
      'src/components/__tests__/.*\.test\.tsx?$' \
      'src/hooks/__tests__/.*\.test\.ts?$'; then
    echo "❌ UI package unit tests failed or coverage below 95%"
    exit 1
  fi
  cd "$(git rev-parse --show-toplevel)"
}

# Validate integration tests
function validate_integration_tests() {
  # Test core-api integration
  cd knowledge/packages/graph-api
  if ! pytest tests/integration/test_core_api.py; then
    echo "❌ Core-API integration tests failed"
    exit 1
  fi
  cd "$(git rev-parse --show-toplevel)"

  # Test api-ui integration
  cd knowledge/packages/graph-ui
  if ! jest 'src/integration/__tests__/.*\.test\.tsx?$'; then
    echo "❌ API-UI integration tests failed"
    exit 1
  fi
  cd "$(git rev-parse --show-toplevel)"

  # Test backend integrations
  cd knowledge/packages/graph-core
  if ! pytest tests/integration/test_backends.py; then
    echo "❌ Backend integration tests failed"
    exit 1
  fi
  cd "$(git rev-parse --show-toplevel)"
}

# Validate performance tests
function validate_performance_tests() {
  # Test core performance
  cd knowledge/packages/graph-core
  if ! pytest tests/performance/; then
    echo "❌ Core performance tests failed"
    exit 1
  fi
  cd "$(git rev-parse --show-toplevel)"

  # Test API performance
  cd knowledge/packages/graph-api
  if ! pytest tests/performance/; then
    echo "❌ API performance tests failed"
    exit 1
  fi
  cd "$(git rev-parse --show-toplevel)"

  # Test UI performance
  cd knowledge/packages/graph-ui
  if ! jest 'src/performance/__tests__/.*\.test\.tsx?$'; then
    echo "❌ UI performance tests failed"
    exit 1
  fi
  cd "$(git rev-parse --show-toplevel)"
}

# Validate test documentation
function validate_test_documentation() {
  # Check test documentation files
  required_docs=(
    "docs/testing/unit-tests.md"
    "docs/testing/integration-tests.md"
    "docs/testing/performance-tests.md"
    "docs/testing/test-coverage.md"
    "docs/testing/test-guidelines.md"
  )

  for doc in "${required_docs[@]}"; do
    if [ ! -f "$doc" ]; then
      echo "❌ Missing test documentation: $doc"
      exit 1
    fi
  done

  # Validate test documentation content
  for doc in "${required_docs[@]}"; do
    if [ ! -s "$doc" ]; then
      echo "❌ Empty test documentation: $doc"
      exit 1
    fi
  done
}

# Run all validations
validate_unit_tests
validate_integration_tests
validate_performance_tests
validate_test_documentation

echo "✅ Comprehensive Testing implementation validated"
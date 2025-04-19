#!/bin/bash
# tools/dev-scripts/task20_validation.sh
# Validates comprehensive testing implementation

set -e

# Ensure we're in the project root
cd "$(git rev-parse --show-toplevel)"

source .venv/bin/activate

# Validate directory structure
function validate_directory_structure() {
  # Check required directories for each package
  packages=("graph-core" "graph-api" "graph-ui")
  for pkg in "${packages[@]}"; do
    cd "knowledge/packages/$pkg"

    required_dirs=(
      "tests/unit"
      "tests/integration"
      "tests/performance"
    )

    for dir in "${required_dirs[@]}"; do
      if [ ! -d "$dir" ]; then
        echo "❌ Missing required directory: $dir in package $pkg"
        echo "Please ensure your directory structure matches the one specified in tasks.md"
        exit 1
      fi
    done

    cd "$(git rev-parse --show-toplevel)"
  done

  # Check documentation structure
  required_docs=(
    "docs/testing/unit-tests.md"
    "docs/testing/integration-tests.md"
    "docs/testing/performance-tests.md"
    "docs/testing/test-coverage.md"
    "docs/testing/test-guidelines.md"
  )

  for doc in "${required_docs[@]}"; do
    if [ ! -f "$doc" ]; then
      echo "❌ Missing required documentation: $doc"
      echo "Please ensure all test documentation is present"
      exit 1
    fi
  done
}

# Validate unit tests
function validate_unit_tests() {
  packages=("graph-core" "graph-api" "graph-ui")
  for pkg in "${packages[@]}"; do
    cd "knowledge/packages/$pkg"

    echo "Running unit tests for $pkg..."
    if ! pytest tests/unit \
        --cov=src \
        --cov-report=term-missing \
        --cov-fail-under=95; then
      echo "❌ Unit tests failed or coverage below 95% for $pkg"
      echo "Please ensure all unit tests pass and maintain at least 95% coverage"
      exit 1
    fi

    cd "$(git rev-parse --show-toplevel)"
  done
}

# Validate integration tests
function validate_integration_tests() {
  packages=("graph-core" "graph-api" "graph-ui")
  for pkg in "${packages[@]}"; do
    cd "knowledge/packages/$pkg"

    echo "Running integration tests for $pkg..."
    if ! pytest tests/integration -v; then
      echo "❌ Integration tests failed for $pkg"
      echo "Please ensure all integration tests pass and components work together correctly"
      exit 1
    fi

    cd "$(git rev-parse --show-toplevel)"
  done
}

# Validate performance tests
function validate_performance_tests() {
  packages=("graph-core" "graph-api" "graph-ui")
  for pkg in "${packages[@]}"; do
    cd "knowledge/packages/$pkg"

    echo "Running performance tests for $pkg..."
    if ! pytest tests/performance -v; then
      echo "❌ Performance tests failed for $pkg"
      echo "Please ensure all performance benchmarks meet requirements"
      exit 1
    fi

    # Check memory profiling results
    if [ -f "tests/performance/memory_profile.json" ]; then
      if ! python -c "import json; data=json.load(open('tests/performance/memory_profile.json')); exit(0 if data['peak_memory_mb'] < 500 else 1)"; then
        echo "❌ Memory usage exceeds limit for $pkg"
        echo "Please optimize memory usage to stay under 500MB peak"
        exit 1
      fi
    fi

    cd "$(git rev-parse --show-toplevel)"
  done
}

# Validate test documentation
function validate_documentation() {
  # Check unit test documentation
  if ! grep -q "Test Guidelines" docs/testing/unit-tests.md; then
    echo "❌ Missing test guidelines in unit test documentation"
    echo "Please ensure unit test documentation includes clear guidelines"
    exit 1
  fi

  # Check integration test documentation
  if ! grep -q "Integration Patterns" docs/testing/integration-tests.md; then
    echo "❌ Missing integration patterns in integration test documentation"
    echo "Please ensure integration test documentation includes common patterns"
    exit 1
  fi

  # Check performance test documentation
  if ! grep -q "Performance Benchmarks" docs/testing/performance-tests.md; then
    echo "❌ Missing performance benchmarks in performance test documentation"
    echo "Please ensure performance test documentation includes benchmark specifications"
    exit 1
  fi

  # Check coverage reporting
  if ! grep -q "Coverage Requirements" docs/testing/test-coverage.md; then
    echo "❌ Missing coverage requirements in test coverage documentation"
    echo "Please ensure test coverage documentation includes minimum requirements"
    exit 1
  fi
}

# Run all validations
echo "Validating directory structure..."
validate_directory_structure

echo "Validating unit tests..."
validate_unit_tests

echo "Validating integration tests..."
validate_integration_tests

echo "Validating performance tests..."
validate_performance_tests

echo "Validating test documentation..."
validate_documentation

echo "✅ Comprehensive testing implementation validated successfully!"
#!/bin/bash
# tools/dev-scripts/task1_validation.sh
# Validates project structure and development environment setup

set -e

# Ensure we're in the project root
cd "$(git rev-parse --show-toplevel)"

# Validate project structure
function validate_structure() {
  required_dirs=("docs" "examples" "knowledge/packages" "tests" "tools")
  for dir in "${required_dirs[@]}"; do
    if [ ! -d "$dir" ]; then
      echo "❌ Missing required directory: $dir"
      exit 1
    fi
  done
}

# Validate package configurations
function validate_package_configs() {
  packages=("graph-core" "graph-service" "graph-api" "graph-builder")
  for pkg in "${packages[@]}"; do
    if [ ! -f "knowledge/packages/$pkg/pyproject.toml" ]; then
      echo "❌ Missing pyproject.toml in $pkg"
      exit 1
    fi
  done
}

# Validate development tools
function validate_dev_tools() {
  source .venv/bin/activate && {
    # Check Ruff configuration
    if ! ruff --version >/dev/null 2>&1; then
      echo "❌ Ruff not properly configured"
      exit 1
    fi

    # Check pytest installation
    if ! pytest --version >/dev/null 2>&1; then
      echo "❌ pytest not properly configured"
      exit 1
    fi

    # Check mypy installation
    if ! mypy --version >/dev/null 2>&1; then
      echo "❌ mypy not properly configured"
      exit 1
    fi
  }
}

# Run all validations
validate_structure
validate_package_configs
validate_dev_tools

echo "✅ Project structure and environment setup validated"
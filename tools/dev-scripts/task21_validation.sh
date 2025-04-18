#!/bin/bash
# tools/dev-scripts/task21_validation.sh
# Validates Documentation implementation

set -e

# Ensure we're in the project root
cd "$(git rev-parse --show-toplevel)"

source .venv/bin/activate

# Validate API documentation
function validate_api_documentation() {
  # Check API documentation files
  required_docs=(
    "docs/api/rest-api.md"
    "docs/api/graphcontext-api.md"
    "docs/api/service-layer-api.md"
    "docs/api/mcp-integration.md"
    "docs/api/examples.md"
  )

  for doc in "${required_docs[@]}"; do
    if [ ! -f "$doc" ]; then
      echo "❌ Missing API documentation: $doc"
      exit 1
    fi
  done

  # Validate OpenAPI documentation generation
  cd knowledge/packages/graph-api
  if ! python -c "
    from fastapi.openapi.utils import get_openapi
    from src.main import app
    assert get_openapi(
        title=app.title,
        version=app.version,
        openapi_version=app.openapi_version,
        description=app.description,
        routes=app.routes,
    )
    "; then
    echo "❌ OpenAPI documentation generation failed"
    exit 1
  fi
  cd "$(git rev-parse --show-toplevel)"
}

# Validate user guides
function validate_user_guides() {
  # Check user guide files
  required_guides=(
    "docs/guides/getting-started.md"
    "docs/guides/graph-explorer.md"
    "docs/guides/schema-editor.md"
    "docs/guides/query-builder.md"
    "docs/guides/llm-integration.md"
    "docs/guides/best-practices.md"
  )

  for guide in "${required_guides[@]}"; do
    if [ ! -f "$guide" ]; then
      echo "❌ Missing user guide: $guide"
      exit 1
    fi
  done

  # Validate guide content
  for guide in "${required_guides[@]}"; do
    if [ ! -s "$guide" ]; then
      echo "❌ Empty user guide: $guide"
      exit 1
    fi
  done
}

# Validate developer documentation
function validate_developer_documentation() {
  # Check developer documentation files
  required_docs=(
    "docs/development/architecture.md"
    "docs/development/components.md"
    "docs/development/setup.md"
    "docs/development/testing.md"
    "docs/development/contributing.md"
    "docs/development/code-style.md"
    "docs/development/backend-integration.md"
  )

  for doc in "${required_docs[@]}"; do
    if [ ! -f "$doc" ]; then
      echo "❌ Missing developer documentation: $doc"
      exit 1
    fi
  done

  # Validate documentation content
  for doc in "${required_docs[@]}"; do
    if [ ! -s "$doc" ]; then
      echo "❌ Empty developer documentation: $doc"
      exit 1
    fi
  done
}

# Validate code documentation
function validate_code_documentation() {
  # Check Python docstrings
  cd knowledge/packages/graph-core
  if ! python -m pydocstyle src/; then
    echo "❌ Core package docstring validation failed"
    exit 1
  fi
  cd "$(git rev-parse --show-toplevel)"

  cd knowledge/packages/graph-api
  if ! python -m pydocstyle src/; then
    echo "❌ API package docstring validation failed"
    exit 1
  fi
  cd "$(git rev-parse --show-toplevel)"

  # Check TypeScript documentation
  cd knowledge/packages/graph-ui
  if ! yarn run typedoc --tsconfig tsconfig.json; then
    echo "❌ UI package documentation generation failed"
    exit 1
  fi
  cd "$(git rev-parse --show-toplevel)"
}

# Validate documentation synchronization
function validate_documentation_sync() {
  # Check if documentation matches current version
  if ! python tools/scripts/validate_docs_version.py; then
    echo "❌ Documentation version mismatch"
    exit 1
  fi

  # Check if API examples are up to date
  if ! python tools/scripts/validate_api_examples.py; then
    echo "❌ API examples are outdated"
    exit 1
  fi
}

# Run all validations
validate_api_documentation
validate_user_guides
validate_developer_documentation
validate_code_documentation
validate_documentation_sync

echo "✅ Documentation implementation validated"
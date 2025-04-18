#!/bin/bash
# tools/dev-scripts/task14_validation.sh
# Validates LLM Pipeline Integration implementation

set -e

# Ensure we're in the project root
cd "$(git rev-parse --show-toplevel)"

source .venv/bin/activate

# Validate implementation
function validate_implementation() {
  cd knowledge/packages/graph-api

  # Check required files
  required_files=(
    "src/llm/pipeline.py"
    "src/llm/config.py"
    "src/llm/prompts.py"
    "src/llm/models.py"
    "src/llm/cache.py"
    "src/llm/callbacks.py"
  )

  for file in "${required_files[@]}"; do
    if [ ! -f "$file" ]; then
      echo "❌ Missing required file: $file"
      exit 1
    fi
  done

  # Validate type checking
  if ! mypy src/llm/; then
    echo "❌ Type checking failed"
    exit 1
  fi

  # Validate code style
  if ! ruff check src/llm/; then
    echo "❌ Code style validation failed"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate LLM pipeline
function validate_llm_pipeline() {
  cd knowledge/packages/graph-api

  # Run pipeline tests
  if ! pytest tests/llm/test_pipeline.py \
      --cov=src/llm/pipeline.py \
      --cov-report=term-missing \
      --cov-fail-under=90; then
    echo "❌ LLM pipeline tests failed or coverage below 90%"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate prompt management
function validate_prompt_management() {
  cd knowledge/packages/graph-api

  # Run prompt tests
  if ! pytest tests/llm/test_prompts.py \
      --cov=src/llm/prompts.py \
      --cov-report=term-missing \
      --cov-fail-under=90; then
    echo "❌ Prompt management tests failed or coverage below 90%"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate model management
function validate_model_management() {
  cd knowledge/packages/graph-api

  # Run model tests
  if ! pytest tests/llm/test_models.py \
      --cov=src/llm/models.py \
      --cov-report=term-missing \
      --cov-fail-under=90; then
    echo "❌ Model management tests failed or coverage below 90%"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate caching system
function validate_caching() {
  cd knowledge/packages/graph-api

  # Run cache tests
  if ! pytest tests/llm/test_cache.py \
      --cov=src/llm/cache.py \
      --cov-report=term-missing \
      --cov-fail-under=90; then
    echo "❌ Caching system tests failed or coverage below 90%"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate callback system
function validate_callbacks() {
  cd knowledge/packages/graph-api

  # Run callback tests
  if ! pytest tests/llm/test_callbacks.py \
      --cov=src/llm/callbacks.py \
      --cov-report=term-missing \
      --cov-fail-under=90; then
    echo "❌ Callback system tests failed or coverage below 90%"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Run all validations
validate_implementation
validate_llm_pipeline
validate_prompt_management
validate_model_management
validate_caching
validate_callbacks

echo "✅ LLM Pipeline Integration implementation validated"
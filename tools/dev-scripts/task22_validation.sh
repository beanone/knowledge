#!/bin/bash
# tools/dev-scripts/task22_validation.sh
# Validates LLM Integration implementation

set -e

# Ensure we're in the project root
cd "$(git rev-parse --show-toplevel)"

source .venv/bin/activate

# Validate directory structure
function validate_directory_structure() {
  cd knowledge/packages/graph-core

  # Check required directories
  required_dirs=(
    "src/llm"
    "src/llm/models"
    "src/llm/prompts"
    "src/llm/chains"
    "src/llm/embeddings"
    "tests/llm"
    "tests/llm/models"
    "tests/llm/prompts"
    "tests/llm/chains"
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
    "src/llm/__init__.py"
    "src/llm/config.py"
    "src/llm/models/base.py"
    "src/llm/models/openai.py"
    "src/llm/models/anthropic.py"
    "src/llm/prompts/templates.py"
    "src/llm/prompts/validation.py"
    "src/llm/chains/graph_qa.py"
    "src/llm/chains/query_generation.py"
    "src/llm/chains/schema_inference.py"
    "src/llm/embeddings/text.py"
    "src/llm/embeddings/graph.py"
    "tests/llm/test_config.py"
    "tests/llm/models/test_openai.py"
    "tests/llm/models/test_anthropic.py"
    "tests/llm/prompts/test_templates.py"
    "tests/llm/chains/test_graph_qa.py"
    "tests/llm/chains/test_query_generation.py"
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
  cd knowledge/packages/graph-core

  # Check type hints
  if ! mypy src/llm; then
    echo "❌ Type checking failed"
    echo "Please ensure all code has proper type annotations"
    exit 1
  fi

  # Validate code formatting
  if ! ruff check src/llm; then
    echo "❌ Code style validation failed"
    echo "Please run 'ruff check --fix src/llm' to fix formatting issues"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate test coverage
function validate_test_coverage() {
  cd knowledge/packages/graph-core

  # Run tests with coverage
  if ! pytest tests/llm \
      --cov=src/llm \
      --cov-report=term-missing \
      --cov-fail-under=90; then
    echo "❌ Tests failed or coverage below 90%"
    echo "Please ensure all tests pass and maintain at least 90% coverage"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate LLM functionality
function validate_llm_functionality() {
  cd knowledge/packages/graph-core

  # Test model integration
  if ! pytest tests/llm/models -v; then
    echo "❌ Model integration tests failed"
    echo "Please ensure LLM models are properly integrated and can handle requests"
    exit 1
  fi

  # Test prompt templates
  if ! pytest tests/llm/prompts/test_templates.py -v; then
    echo "❌ Prompt template tests failed"
    echo "Please ensure prompt templates are properly formatted and validated"
    exit 1
  fi

  # Test QA chain
  if ! pytest tests/llm/chains/test_graph_qa.py -v; then
    echo "❌ Graph QA chain tests failed"
    echo "Please ensure the QA chain can process graph-based queries correctly"
    exit 1
  fi

  # Test query generation
  if ! pytest tests/llm/chains/test_query_generation.py -v; then
    echo "❌ Query generation tests failed"
    echo "Please ensure natural language to graph query conversion works correctly"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate prompt management
function validate_prompt_management() {
  cd knowledge/packages/graph-core

  # Check prompt versioning
  if ! python -c "
    from src.llm.prompts import templates
    assert hasattr(templates, 'TEMPLATE_VERSION')
    assert hasattr(templates, 'get_prompt_template')
    "; then
    echo "❌ Prompt versioning validation failed"
    echo "Please ensure proper prompt versioning and template management"
    exit 1
  fi

  # Check prompt validation
  if ! python -c "
    from src.llm.prompts import validation
    assert hasattr(validation, 'validate_prompt_template')
    assert hasattr(validation, 'PromptValidationError')
    "; then
    echo "❌ Prompt validation checks failed"
    echo "Please ensure proper prompt validation mechanisms are in place"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate model configuration
function validate_model_configuration() {
  cd knowledge/packages/graph-core

  # Check model configuration
  if ! python -c "
    from src.llm import config
    assert hasattr(config, 'LLMConfig')
    assert hasattr(config, 'get_default_config')
    "; then
    echo "❌ Model configuration validation failed"
    echo "Please ensure proper model configuration management"
    exit 1
  fi

  # Check environment variables
  required_env_vars=(
    "OPENAI_API_KEY"
    "ANTHROPIC_API_KEY"
    "LLM_MODEL_NAME"
    "LLM_TEMPERATURE"
    "LLM_MAX_TOKENS"
  )

  for var in "${required_env_vars[@]}"; do
    if ! grep -q "$var" src/llm/config.py; then
      echo "❌ Missing environment variable: $var"
      echo "Please ensure all required environment variables are configured"
      exit 1
    fi
  done

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

echo "Validating LLM functionality..."
validate_llm_functionality

echo "Validating prompt management..."
validate_prompt_management

echo "Validating model configuration..."
validate_model_configuration

echo "✅ LLM Integration implementation validated successfully!"
#!/bin/bash
# tools/dev-scripts/task12_validation.sh
# Validates GraphBuilder Core implementation

set -e

# Ensure we're in the project root
cd "$(git rev-parse --show-toplevel)"

source .venv/bin/activate

# Validate implementation
function validate_implementation() {
  cd knowledge/packages/graph-builder

  # Check required files
  required_files=(
    "src/processors/document_processor.py"
    "src/extractors/entity_extractor.py"
    "src/extractors/relation_extractor.py"
    "src/models/llm_config.py"
    "src/models/extraction_schema.py"
  )

  for file in "${required_files[@]}"; do
    if [ ! -f "$file" ]; then
      echo "❌ Missing required file: $file"
      exit 1
    fi
  done

  # Validate type checking
  if ! mypy src/; then
    echo "❌ Type checking failed"
    exit 1
  fi

  # Validate code style
  if ! ruff check src/; then
    echo "❌ Code style validation failed"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate document processing
function validate_document_processing() {
  cd knowledge/packages/graph-builder

  # Run document processing tests
  if ! pytest tests/processors/test_document_processor.py \
      --cov=src/processors \
      --cov-report=term-missing \
      --cov-fail-under=85; then
    echo "❌ Document processing tests failed or coverage below 85%"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate entity extraction
function validate_entity_extraction() {
  cd knowledge/packages/graph-builder

  # Run entity extraction tests
  if ! pytest tests/extractors/test_entity_extractor.py \
      --cov=src/extractors/entity_extractor.py \
      --cov-report=term-missing \
      --cov-fail-under=85; then
    echo "❌ Entity extraction tests failed or coverage below 85%"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate relation inference
function validate_relation_inference() {
  cd knowledge/packages/graph-builder

  # Run relation inference tests
  if ! pytest tests/extractors/test_relation_extractor.py \
      --cov=src/extractors/relation_extractor.py \
      --cov-report=term-missing \
      --cov-fail-under=85; then
    echo "❌ Relation inference tests failed or coverage below 85%"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate LLM integration
function validate_llm_integration() {
  cd knowledge/packages/graph-builder

  # Run LLM integration tests
  if ! pytest tests/integration/test_llm_pipeline.py; then
    echo "❌ LLM integration tests failed"
    exit 1
  fi

  # Check LLM configuration
  if ! python -c "
    from src.models.llm_config import LLMConfig
    config = LLMConfig()
    assert config.validate()
    "; then
    echo "❌ LLM configuration validation failed"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Run all validations
validate_implementation
validate_document_processing
validate_entity_extraction
validate_relation_inference
validate_llm_integration

echo "✅ GraphBuilder Core implementation validated"
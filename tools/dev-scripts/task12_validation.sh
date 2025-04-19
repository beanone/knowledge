#!/bin/bash
# tools/dev-scripts/task12_validation.sh
# Validates GraphBuilder Core implementation

set -e

# Ensure we're in the project root
cd "$(git rev-parse --show-toplevel)"

source .venv/bin/activate

# Validate directory structure
function validate_directory_structure() {
  cd knowledge/packages/graph-builder

  # Check required directories
  required_dirs=(
    "src/processors"
    "src/extractors"
    "src/llm"
    "src/models"
    "tests/processors"
    "tests/extractors"
    "tests/llm"
    "tests/models"
    "tests/integration"
  )

  for dir in "${required_dirs[@]}"; do
    if [ ! -d "$dir" ]; then
      echo "❌ Missing required directory: $dir"
      exit 1
    fi
  done

  # Check required files
  required_files=(
    "src/processors/__init__.py"
    "src/processors/document.py"
    "src/processors/text.py"
    "src/processors/media.py"
    "src/extractors/__init__.py"
    "src/extractors/entity.py"
    "src/extractors/relation.py"
    "src/extractors/concepts.py"
    "src/llm/__init__.py"
    "src/llm/client.py"
    "src/llm/prompts.py"
    "src/llm/callbacks.py"
    "src/models/__init__.py"
    "src/models/document.py"
    "src/models/extraction.py"
    "src/__init__.py"
    "tests/processors/__init__.py"
    "tests/processors/test_document.py"
    "tests/processors/test_text.py"
    "tests/processors/test_media.py"
    "tests/extractors/__init__.py"
    "tests/extractors/test_entity.py"
    "tests/extractors/test_relation.py"
    "tests/extractors/test_concepts.py"
    "tests/llm/__init__.py"
    "tests/llm/test_client.py"
    "tests/llm/test_prompts.py"
    "tests/models/__init__.py"
    "tests/models/test_document.py"
    "tests/models/test_extraction.py"
    "tests/integration/__init__.py"
    "tests/integration/test_pipeline.py"
  )

  for file in "${required_files[@]}"; do
    if [ ! -f "$file" ]; then
      echo "❌ Missing required file: $file"
      exit 1
    fi
  done

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate document processing
function validate_document_processing() {
  cd knowledge/packages/graph-builder

  # Run document processing tests
  if ! pytest tests/processors/ \
      --cov=src/processors \
      --cov-report=term-missing \
      --cov-fail-under=85; then
    echo "❌ Document processing tests failed or coverage below 85%"
    exit 1
  fi

  # Validate multiple format support
  if ! python -c "from src.processors.document import DocumentProcessor; assert len(DocumentProcessor.supported_formats) > 1"; then
    echo "❌ Document processor missing multiple format support"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate extraction system
function validate_extraction() {
  cd knowledge/packages/graph-builder

  # Run extraction tests
  if ! pytest tests/extractors/ \
      --cov=src/extractors \
      --cov-report=term-missing \
      --cov-fail-under=85; then
    echo "❌ Extraction system tests failed or coverage below 85%"
    exit 1
  fi

  # Validate configurable rules
  if ! python -c "from src.extractors.entity import EntityExtractor; assert hasattr(EntityExtractor, 'configure_rules')"; then
    echo "❌ Entity extractor missing configurable rules"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate LLM integration
function validate_llm() {
  cd knowledge/packages/graph-builder

  # Run LLM tests
  if ! pytest tests/llm/ \
      --cov=src/llm \
      --cov-report=term-missing \
      --cov-fail-under=85; then
    echo "❌ LLM integration tests failed or coverage below 85%"
    exit 1
  fi

  # Validate error handling and retries
  if ! python -c "from src.llm.client import LLMClient; assert hasattr(LLMClient, 'retry_config') and hasattr(LLMClient, 'error_handler')"; then
    echo "❌ LLM client missing error handling or retries"
    exit 1
  fi

  # Validate prompt versioning
  if ! python -c "from src.llm.prompts import PromptTemplate; assert hasattr(PromptTemplate, 'version')"; then
    echo "❌ Prompt templates missing versioning"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate models and type hints
function validate_models() {
  cd knowledge/packages/graph-builder

  # Run model tests
  if ! pytest tests/models/ \
      --cov=src/models \
      --cov-report=term-missing \
      --cov-fail-under=85; then
    echo "❌ Model tests failed or coverage below 85%"
    exit 1
  fi

  # Validate type hints
  if ! mypy src/; then
    echo "❌ Type checking failed"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate integration
function validate_integration() {
  cd knowledge/packages/graph-builder

  # Run integration tests
  if ! pytest tests/integration/test_pipeline.py; then
    echo "❌ Integration tests failed"
    exit 1
  fi

  # Validate GraphManager integration
  if ! python -c "from src.processors.document import DocumentProcessor; from src.services.graph_manager import GraphManager; assert issubclass(DocumentProcessor, GraphManager)"; then
    echo "❌ Document processor is not properly integrated with GraphManager"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Run all validations
echo "Validating directory structure..."
validate_directory_structure

echo "Validating document processing..."
validate_document_processing

echo "Validating extraction system..."
validate_extraction

echo "Validating LLM integration..."
validate_llm

echo "Validating models and type hints..."
validate_models

echo "Validating integration..."
validate_integration

echo "✅ GraphBuilder Core implementation validated"
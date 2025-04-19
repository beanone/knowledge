#!/bin/bash
# tools/dev-scripts/task23_validation.sh
# Validates Vector Search implementation

set -e

# Ensure we're in the project root
cd "$(git rev-parse --show-toplevel)"

source .venv/bin/activate

# Validate directory structure
function validate_directory_structure() {
  cd knowledge/packages/graph-core

  # Check required directories
  required_dirs=(
    "src/vector"
    "src/vector/models"
    "src/vector/indexes"
    "src/vector/storage"
    "tests/vector"
    "tests/vector/models"
    "tests/vector/indexes"
    "tests/vector/storage"
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
    "src/vector/__init__.py"
    "src/vector/config.py"
    "src/vector/models/base.py"
    "src/vector/models/sentence_transformer.py"
    "src/vector/models/openai.py"
    "src/vector/indexes/faiss.py"
    "src/vector/indexes/annoy.py"
    "src/vector/storage/vector_store.py"
    "src/vector/storage/metadata.py"
    "tests/vector/test_config.py"
    "tests/vector/models/test_sentence_transformer.py"
    "tests/vector/models/test_openai.py"
    "tests/vector/indexes/test_faiss.py"
    "tests/vector/indexes/test_annoy.py"
    "tests/vector/storage/test_vector_store.py"
    "tests/vector/storage/test_metadata.py"
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
  if ! mypy src/vector; then
    echo "❌ Type checking failed"
    echo "Please ensure all code has proper type annotations"
    exit 1
  fi

  # Validate code formatting
  if ! ruff check src/vector; then
    echo "❌ Code style validation failed"
    echo "Please run 'ruff check --fix src/vector' to fix formatting issues"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate test coverage
function validate_test_coverage() {
  cd knowledge/packages/graph-core

  # Run tests with coverage
  if ! pytest tests/vector \
      --cov=src/vector \
      --cov-report=term-missing \
      --cov-fail-under=90; then
    echo "❌ Tests failed or coverage below 90%"
    echo "Please ensure all tests pass and maintain at least 90% coverage"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate embedding models
function validate_embedding_models() {
  cd knowledge/packages/graph-core

  # Test sentence transformers
  if ! pytest tests/vector/models/test_sentence_transformer.py -v; then
    echo "❌ Sentence transformer tests failed"
    echo "Please ensure sentence transformer model works correctly"
    exit 1
  fi

  # Test OpenAI embeddings
  if ! pytest tests/vector/models/test_openai.py -v; then
    echo "❌ OpenAI embedding tests failed"
    echo "Please ensure OpenAI embedding integration works correctly"
    exit 1
  fi

  # Check model configuration
  if ! python -c "
    from src.vector.models.base import BaseEmbeddingModel
    from src.vector.models.sentence_transformer import SentenceTransformerModel
    from src.vector.models.openai import OpenAIEmbeddingModel
    assert issubclass(SentenceTransformerModel, BaseEmbeddingModel)
    assert issubclass(OpenAIEmbeddingModel, BaseEmbeddingModel)
    "; then
    echo "❌ Model inheritance validation failed"
    echo "Please ensure proper model inheritance hierarchy"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate vector indexes
function validate_vector_indexes() {
  cd knowledge/packages/graph-core

  # Test FAISS index
  if ! pytest tests/vector/indexes/test_faiss.py -v; then
    echo "❌ FAISS index tests failed"
    echo "Please ensure FAISS index implementation works correctly"
    exit 1
  fi

  # Test Annoy index
  if ! pytest tests/vector/indexes/test_annoy.py -v; then
    echo "❌ Annoy index tests failed"
    echo "Please ensure Annoy index implementation works correctly"
    exit 1
  fi

  # Check index performance
  if ! python -c "
    import json
    with open('tests/vector/indexes/benchmark_results.json') as f:
        results = json.load(f)
    assert results['faiss_recall_at_10'] > 0.95
    assert results['annoy_recall_at_10'] > 0.90
    "; then
    echo "❌ Index performance validation failed"
    echo "Please ensure indexes meet recall requirements"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate vector storage
function validate_vector_storage() {
  cd knowledge/packages/graph-core

  # Test vector store
  if ! pytest tests/vector/storage/test_vector_store.py -v; then
    echo "❌ Vector store tests failed"
    echo "Please ensure vector store implementation works correctly"
    exit 1
  fi

  # Test metadata storage
  if ! pytest tests/vector/storage/test_metadata.py -v; then
    echo "❌ Metadata storage tests failed"
    echo "Please ensure metadata storage works correctly"
    exit 1
  fi

  # Check persistence
  if ! python -c "
    from src.vector.storage.vector_store import VectorStore
    store = VectorStore.load('tests/vector/storage/test_store')
    assert len(store) > 0
    assert store.dimension == 768
    "; then
    echo "❌ Vector store persistence validation failed"
    echo "Please ensure vector store can be properly persisted and loaded"
    exit 1
  fi

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

echo "Validating embedding models..."
validate_embedding_models

echo "Validating vector indexes..."
validate_vector_indexes

echo "Validating vector storage..."
validate_vector_storage

echo "✅ Vector Search implementation validated successfully!"
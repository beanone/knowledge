#!/bin/bash
# tools/dev-scripts/task14_validation.sh
# Validates LLM Pipeline Integration implementation

set -e

# Ensure we're in the project root
cd "$(git rev-parse --show-toplevel)"

source .venv/bin/activate

# Validate directory structure
function validate_directory_structure() {
  cd knowledge/packages/graph-api

  # Check required directories
  required_dirs=(
    "src/llm_pipeline"
    "src/services"
    "src/models"
    "tests/llm_pipeline"
    "tests/services"
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
    "src/llm_pipeline/__init__.py"
    "src/llm_pipeline/embeddings.py"
    "src/llm_pipeline/similarity.py"
    "src/llm_pipeline/nlp_processor.py"
    "src/llm_pipeline/cache.py"
    "src/llm_pipeline/callbacks.py"
    "src/services/__init__.py"
    "src/services/vector_store.py"
    "src/services/query_parser.py"
    "src/models/__init__.py"
    "src/models/embeddings.py"
    "src/models/queries.py"
    "src/models/results.py"
    "src/__init__.py"
    "tests/llm_pipeline/__init__.py"
    "tests/llm_pipeline/test_embeddings.py"
    "tests/llm_pipeline/test_similarity.py"
    "tests/llm_pipeline/test_nlp_processor.py"
    "tests/llm_pipeline/test_cache.py"
    "tests/llm_pipeline/test_callbacks.py"
    "tests/services/__init__.py"
    "tests/services/test_vector_store.py"
    "tests/services/test_query_parser.py"
    "tests/models/__init__.py"
    "tests/models/test_embeddings.py"
    "tests/models/test_queries.py"
    "tests/models/test_results.py"
    "tests/integration/__init__.py"
    "tests/integration/test_llm_pipeline.py"
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

# Validate embedding system
function validate_embeddings() {
  cd knowledge/packages/graph-api

  # Run embedding tests
  if ! pytest tests/llm_pipeline/test_embeddings.py tests/models/test_embeddings.py \
      --cov=src/llm_pipeline/embeddings.py \
      --cov=src/models/embeddings.py \
      --cov-report=term-missing \
      --cov-fail-under=90; then
    echo "❌ Embedding system tests failed or coverage below 90%"
    exit 1
  fi

  # Validate configurable models
  if ! python -c "from src.llm_pipeline.embeddings import EmbeddingGenerator; assert hasattr(EmbeddingGenerator, 'configure_model')"; then
    echo "❌ Embedding system missing model configuration"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate similarity search
function validate_similarity() {
  cd knowledge/packages/graph-api

  # Run similarity tests
  if ! pytest tests/llm_pipeline/test_similarity.py \
      --cov=src/llm_pipeline/similarity.py \
      --cov-report=term-missing \
      --cov-fail-under=90; then
    echo "❌ Similarity search tests failed or coverage below 90%"
    exit 1
  fi

  # Validate indexing
  if ! python -c "from src.llm_pipeline.similarity import SimilaritySearch; assert hasattr(SimilaritySearch, 'build_index') and hasattr(SimilaritySearch, 'update_index')"; then
    echo "❌ Similarity search missing indexing functionality"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate NLP processing
function validate_nlp() {
  cd knowledge/packages/graph-api

  # Run NLP tests
  if ! pytest tests/llm_pipeline/test_nlp_processor.py tests/services/test_query_parser.py \
      --cov=src/llm_pipeline/nlp_processor.py \
      --cov=src/services/query_parser.py \
      --cov-report=term-missing \
      --cov-fail-under=90; then
    echo "❌ NLP processing tests failed or coverage below 90%"
    exit 1
  fi

  # Validate complex query handling
  if ! python -c "from src.services.query_parser import QueryParser; assert hasattr(QueryParser, 'parse_complex_query')"; then
    echo "❌ Query parser missing complex query handling"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate caching and callbacks
function validate_infrastructure() {
  cd knowledge/packages/graph-api

  # Run infrastructure tests
  if ! pytest tests/llm_pipeline/test_cache.py tests/llm_pipeline/test_callbacks.py \
      --cov=src/llm_pipeline/cache.py \
      --cov=src/llm_pipeline/callbacks.py \
      --cov-report=term-missing \
      --cov-fail-under=90; then
    echo "❌ Infrastructure tests failed or coverage below 90%"
    exit 1
  fi

  # Validate configurable cache backends
  if ! python -c "from src.llm_pipeline.cache import CacheManager; assert hasattr(CacheManager, 'configure_backend')"; then
    echo "❌ Cache system missing backend configuration"
    exit 1
  fi

  # Validate pipeline monitoring
  if ! python -c "from src.llm_pipeline.callbacks import PipelineCallbacks; assert all(hasattr(PipelineCallbacks, event) for event in ['on_start', 'on_error', 'on_complete'])"; then
    echo "❌ Callback system missing required monitoring events"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate vector store
function validate_vector_store() {
  cd knowledge/packages/graph-api

  # Run vector store tests
  if ! pytest tests/services/test_vector_store.py \
      --cov=src/services/vector_store.py \
      --cov-report=term-missing \
      --cov-fail-under=90; then
    echo "❌ Vector store tests failed or coverage below 90%"
    exit 1
  fi

  # Validate embedding management
  if ! python -c "from src.services.vector_store import VectorStore; assert all(hasattr(VectorStore, op) for op in ['store', 'retrieve', 'update', 'delete'])"; then
    echo "❌ Vector store missing required operations"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate type hints and API docs
function validate_code_quality() {
  cd knowledge/packages/graph-api

  # Validate type checking
  if ! mypy src/llm_pipeline/ src/services/ src/models/; then
    echo "❌ Type checking failed"
    exit 1
  fi

  # Validate OpenAPI documentation
  if ! python -c "from fastapi.openapi.utils import get_openapi; from src.main import app; spec = get_openapi(title=app.title, version=app.version, routes=app.routes); assert any('/llm' in path for path in spec['paths'])"; then
    echo "❌ OpenAPI documentation validation failed"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Validate integration
function validate_integration() {
  cd knowledge/packages/graph-api

  # Run integration tests
  if ! pytest tests/integration/test_llm_pipeline.py; then
    echo "❌ Integration tests failed"
    exit 1
  fi

  # Validate GraphBuilder integration
  if ! python -c "from src.llm_pipeline.nlp_processor import NLPProcessor; from src.services.graph_builder import GraphBuilder; assert issubclass(NLPProcessor, GraphBuilder)"; then
    echo "❌ NLP processor not properly integrated with GraphBuilder"
    exit 1
  fi

  # Validate QueryService integration
  if ! python -c "from src.llm_pipeline.nlp_processor import NLPProcessor; from src.services.query import QueryService; assert hasattr(NLPProcessor, 'query_service')"; then
    echo "❌ NLP processor not properly integrated with QueryService"
    exit 1
  fi

  # Return to project root
  cd "$(git rev-parse --show-toplevel)"
}

# Run all validations
echo "Validating directory structure..."
validate_directory_structure

echo "Validating embeddings..."
validate_embeddings

echo "Validating similarity..."
validate_similarity

echo "Validating NLP processing..."
validate_nlp

echo "Validating infrastructure..."
validate_infrastructure

echo "Validating vector store..."
validate_vector_store

echo "Validating code quality..."
validate_code_quality

echo "Validating integration..."
validate_integration

echo "✅ LLM Pipeline Integration implementation validated"
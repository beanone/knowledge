---
description: Guides the development process and implementation standards for the Knowledge Graph IDE
globs:
  - "knowledge/packages/*/src/**/*.py"
  - "knowledge/packages/*/tests/**/*.py"
  - "tools/dev-scripts/*.sh"
  - "docs/**/*.md"
alwaysApply: true
---

# Knowledge Graph Assisted Research IDE Development Rules

## Purpose and Usage Guidelines

This document serves as the authoritative guide for development practices in the Knowledge Graph Assisted Research IDE projs, processes, and best practices that ensure consistent, high-quality implementation across all components.

### How to Use This Document

1. **Task Planning and Validation**:
   - Before starting any task, review `docs/plan/tasks.md` to understand:
     - Task dependencies and prerequisites
     - Sub-tasks and their sequence
     - Acceptance criteria
     - Associated validation script
   - Compare these against the architecture documents in `docs/architecture/`
   - If you identify any discrepancies or needed adjustments to sub-tasks, acceptance criteria, or validation scripts, raise these concerns bportant**: Do not modify planned tasks or validation criteria without explicit approval

2. **Implementation Process**:
   - Follow the [Task Implementation Process](#34-task-implementation-process) section
   - Use the validation scripts as your primary guide for requirements
   - Ensure compliance with all relevant sections of this document:
     - Architecture rules for your component
     - Code organization standards
     - Testing requirements
     - Performance targets
     - Security considerations

## Table of Contents
- [1. System Architecture Rules](#1-system-architecture-rules)
  - [1.1 Graph Core Principles](#11-graph-core-principles)
  - [1.2 Service Layer Rules](#12-service-layer-rules)
  - [1.3 API Design Rules](#13-api-design-rules)
- [2. Code Organization Rules](#2-code-organization-rules)
  - [2.1 Package Structure](#21-package-structure)
  - [2.2 Naming Conventions](#22-naming-conventions)
- [3. Development Process Rules](#3-development-process-rules)
  - [3.1 Git Workflow](#31-git-workflow)
  - [3.2 Testing Requirements](#32-testing-requirements)
  - [3.3 Documentation Requirements](#33-documentation-requirements)
  - [3.4 Task Implementation Process](#34-task-implementation-process)
  - [3.5 Component Refactoring Process](#35-component-refactoring-process)
  - [3.6 Implementation and Refactoring Best Practices](#36-implementation-and-refactoring-best-practices)
  - [3.7 Common Pitfalls to Avoid](#37-common-pitfalls-to-avoid)
- [4. Performance Rules](#4-performance-rules)
  - [4.1 Graph Operations](#41-graph-operations)
  - [4.2 API Performance](#42-api-performance)
- [5. Security Rules](#5-security-rules)
  - [5.1 Authentication & Authorization](#51-authentication--authorization)
  - [5.2 Data Security](#52-data-security)
- [6. Monitoring Rules](#6-monitoring-rules)
  - [6.1 Logging](#61-logging)
  - [6.2 Metrics](#62-metrics)
- [7. Dependency Management](#7-dependency-management)
  - [7.1 Multi-Package Strategy](#71-multi-package-strategy)
  - [7.2 Inter-Package Dependencies](#72-inter-package-dependencies)
- [8. LLM Integration Rules](#8-llm-integration-rules)
  - [8.1 GraphBuilder Integration](#81-graphbuilder-integration)
  - [8.2 MCP Tool Definitions](#82-mcp-tool-definitions)
- [9. Error Handling](#9-error-handling)
  - [9.1 Exception Hierarchy](#91-exception-hierarchy)
  - [9.2 Error Handling Strategies](#92-error-handling-strategies)
  - [9.3 Error Recovery](#93-error-recovery)

## 1. System Architecture Rules

### 1.1 Graph Core Principles
- **Immutable Graph Operations**: All graph modification operations must be immutable by default
- **Type Safety**: All graph entities must have explicit type definitions
- **Transaction Boundaries**: All graph modifications must be wrapped in transactions
- **Validation First**: All operations must validate input before execution
- **Atomic Operations**: Ensure all graph operations are atomic and reversible

#### 1.1.4 Current Design Decisions
- **Single-User Focus**: Current implementation focuses on single-user scenarios
  - No concurrent write operations from multiple users
  - Simplified authentication and authorization
  - Local-first operations prioritized
  - File-system based project isolation

#### 1.1.5 Future Enhancement Guidelines
- **Multi-User Support** (Future)
  - User isolation implementation
  - Concurrent operation handling
  - Permission model implementation
  - Session management
- **Named Graphs Implementation** (Future)
  - Context separation requirements
  - Version tracking implementation
  - Migration path from single-context model
- **Reification Support** (Future)
  - Metadata attachment methods
  - Statement tracking implementation
  - Performance considerations
- **Inference Rules Implementation** (Future)
  - Rule definition format
  - Execution strategy
  - Performance optimization guidelines

### 1.2 Service Layer Rules
- **Stateless Services**: Services must be stateless and idempotent except for:
  - GraphManager: Manages transactions and multi-step operations
  - QueryService: Handles query building and caching
  - EntityService: Manages entity workflows
  - RelationService: Manages relationship workflows
- **Dependency Injection**: Use FastAPI's dependency injection for service composition
- **Circuit Breakers**: Implement circuit breakers for external service calls
- **Rate Limiting**: Apply rate limiting for resource-intensive operations
- **Caching Strategy**: Define explicit caching policies for each service

### 1.3 API Design Rules
- **Tenant-Based Routing**: Use `/tenants/{tenant_id}/graphs/{graph_id}/...`
- **Resource Naming**: Use plural nouns for resources (e.g., `/graphs`, `/entities`)
- **Query Parameters**: Standardize query parameter naming (e.g., `filter`, `sort`, `page`)
- **Response Format**: Use consistent response envelope structure
- **Error Handling**: Implement standardized error responses

## 2. Code Organization Rules

### 2.1 Package Structure
```
repository_root/
├── docs/                    # Project documentation
│   ├── architecture/       # System design and architecture docs
│   ├── api/               # API documentation
│   └── guides/           # Development and user guides
├── examples/               # Usage examples and tutorials
│   ├── basic/            # Basic usage examples
│   ├── advanced/         # Advanced usage examples
│   └── notebooks/        # Jupyter notebooks with examples
├── knowledge/              # Main project directory
│   ├── packages/
│   │   ├── graph-core/          # Core graph operations and data structures
│   │   │   ├── pyproject.toml   # Package-specific dependencies
│   │   │   ├── src/
│   │   │   |   ├── entities/    # Entity type definitions
│   │   │   |   ├── operations/  # Graph operations
│   │   │   |   ├── validation/  # Validation rules
│   │   │   |   └── types/      # Type definitions
|   |   |   └── tests/
|   |   |
│   │   ├── graph-service/       # Business logic and service layer
│   │   │   ├── pyproject.toml
│   │   │   ├── src/
│   │   │   |   ├── services/   # Business logic
│   │   │   |   ├── repositories/ # Data access
│   │   │   |   └── models/     # Service models
|   |   |   └── tests/
|   |   |
│   │   ├── graph-api/           # REST API and MCP integration
│   │   │   ├── pyproject.toml
│   │   │   ├── src/
│   │   │   |   ├── routes/     # API endpoints
│   │   │   |   ├── schemas/    # Pydantic models
│   │   │   |   └── middleware/ # API middleware
|   |   |   └── tests/
|   |   |
│   │   └── graph-builder/       # LLM-based knowledge extraction
│   │       ├── pyproject.toml
│   │       ├── src/
│   │       |   ├── parsers/    # Input parsers
│   │       |   ├── transformers/ # Data transformers
│   │       |   └── validators/ # Input validators
|   |       └── tests/
|   |
│   └── pyproject.toml           # Root project configuration
├── tests/                  # Integration and end-to-end tests
│   ├── integration/       # Integration tests
│   └── e2e/              # End-to-end tests
├── README.md              # Project overview and quick start
├── CONTRIBUTING.md        # Contribution guidelines
└── LICENSE               # License information
```

### 2.2 Naming Conventions
- **Classes**: PascalCase (e.g., `GraphManager`)
- **Functions**: snake_case (e.g., `create_graph`)
- **Var `graph_id`)
- **Constants**: UPPER_SNAKE_CASE (e.g., `MAX_GRAPH_SIZE`)
- **Private Members**: Prefix with underscore (e.g., `_internal_method`)

## 3. Development Process Rules

### 3.1 Git Workflow
- **Branch Naming**: `feature/`, `bugfix/`, `hotfix/`, `release/` prefixes
- **Commit Messages**: Follow conventional commits format
- **Pull Requests**: Require at least one review before merging
- **Squash Merging**: Use squash merge for feature branches
- **Protected Branches**: `main` and `develop` branches are protected

### 3.2 Testing Requirements
- **Coverage Requirements by Component**:
  - graph-core: 95% coverage (critical component)
  - graph-service: 90% coverage
  - graph-api: 90% coverage
  - graph-builder: 85% coverage (excluding LLM components)
- **Test Categories**:
  - Unit tests for all functions
  - Integration tests for services
  - API tests for endpoints
  - Performance tests for critical paths
- **Test Naming**: `test_<function>_<scenario>`
- **Test Data**: Use fixtures for complex test data

### 3.3 Documentation Requirements
- **Code Documentation**: Google-style docstrings for all public interfaces
- **API Documentation**: OpenAPI/Swagger for all endpoints
- **Architecture Documentation**: Keep architecture diagrams updated
- **Decision Records**: Document significant design decisions
- **Tutorials**: Provide usage examples and tutorials

### 3.4 Task Implementation Process

#### 3.4.1 Task Preparation
```bash
# 1. Activate virtual environment
source .venv/bin/activate

# 2. Create a feature branch (format: feature/task-XX-descriptio XX is zero-padded task number)
git checkout -b feature/task-13-mcp-integration

# 3. Make validation script executable
chmod +x tools/dev-scripts/task13_validation.sh

# 4. Run validation to understand requirements
./tools/dev-scripts/task13_validation.sh
```

#### 3.4.2 Implementation Steps

1. **Review Requirements** (see [Documentation Requirements](#33-documentation-requirements))
   - Read the task description in `docs/plan/tasks.md`
   - Review architecture documents in `docs/architecture/`
   - Understand validation requirements from `tools/dev-scripts/taskXX_validation.sh`
   - Check dependencies on other tasks

2. **Plan Implementation**
   - Break down the task into smaller components
   - ed packages and modules
   - List required changes and additions
   - Consider test coverage requirements (see [Testing Requirements](#32-testing-requirements))

3. **Iterative Development**
   ```bash
   # Ensure virtual environment is active
   source .venv/bin/activate

   # Run validation after each significant change
   ./tools/dev-scripts/task13_validation.sh

   # Run affected package tests with coverage
   cd knowledge/packages/graph-api
   poetry run pytest tests/ --cov=src --cov-report=term-missing

   # Check code style with ruff
   poetry run ruff check .

   # Run type checking
   poetry run mypy .
   ```

4. **Documentation**
   - Update relevant documentation in `docs/`
   - Add docstrings to new functions/classes
   - Update package README if needed
   - Document any configuration changes

5. **Final Validation**
   ```bash
   # Ensure all validation passes
   ./tools/dev-scripts/task13_validation.sh

   # Run ful-scripts/run-all-tests.sh
   ```

#### 3.4.3 Code Review Preparation
- Clean up commits with meaningful messages
- Update PR template with implementation details
- Link to releva List manual testing performed
- Note any configuration changes needed

### 3.5 Component Refactoring Process

#### 3.5.1 Pre-Refactoring Analysis

1. **Impact Assessment** (see [Testing Requirements](#32-testing-requirements))
   - Identify all dependent components
   - Review test coverage of affected code
   - Check for cross-package dependencies
   - Document current behavior for regression testing

2. **Planning**
   - Define clear refactoring goals
   - List expected improvetify potential risks
   - Create rollback plan if needed

#### 3.5.1. **Setup**
   ```bash
   # 1. Activate virtual environment
   source .venv/bin/actiate refactor branch
   git checkout -b refactor/component-name-description

   # 3. Run relevant validation scripts
   for script in tools/dev-scripts/task{06..07}_validation.sh; do
     $script
   done
   ```

2. **Iterative Refactoring** (see [Best Practices](#36-implementation-and-refactoring-best-practices))
   - Make small, focused changes
   - Run tests after each change
   - Maintain backward compatibility
   - Update documentation inline

3. **Testing Strategy**
   ```bash
   # Ensure virtual environment is active
   sourcctivate

   # Run affected package tests with coverage
   cd knowledge/packages/graph-core
   poetry run pytest tests/ --cov=src --cov-report=term-missing

   # Run integration tests if applicable
   poetry run pytest tests/integration --cov=src --cov-report=term-missing

   # Check performance impact
   poetry run pytest tests/performance
   ```

#### 3.5.3 Validation and Review

1. **Code Quality**
   ```bash
   # Ensure virtual environment is active
   source .venv/bin/activate

   # Style checks with ruff
   poetry run ruff check .

   # Type checking
   poetry run mypy .

   # Coverage verification
   poetry run pytest --cov=src --cov-report=term-missing
   ```

2. **Documentation Updates** (see [Documentation Requirements](#33-documentation-requirements))
   - Update API documentation
   - Revise architecture diagrams if needed
   - Update package dependencies
   - Document breaking changes

3. **Performance Verification** (see [Performance Rules](#4-performance-rules))
   - Run benchmarks before/after
   - Check memory usage
   - Verify response times
   - Test under load if applicable

#### 3.5.4 Migration Guide

If the refactoring affects other developers:

1. **Communication**
   - Announce changes in team channels
   - Document migration steps
   - Provide examples of updated usage
   - Set deprecation timelines if applicable
   - Create migration documentation in `docs/migrations/`

2. **Support**
   - Create migration scripts if needed (see [Error Handling](#9-error-handling))
   - Update CI/CD pipelines
   - Provide testing guidelines (see [Testing Requirements](#32-testing-requirements))
   - Document rollback procedures
   - Set up monitoring for migration issues (see [Monitoring Rules](#6-monitoring-rules))

3. **Timeline**
   - Establish clear migration deadlines
   - Plan for staged rollout if needed
   - Schedule support office hours
   - Define success criteria for migration

4. **Validation**
   - Create validation scripts for migrated code
   - Set up automated tests for migration
   - Monitor performance metrics during migration
   - Track migration progress

### 3.6 Implementation and Refactoring Best Practices

#### 3.6.1 Implementation Best Practices
1. **Incremental Progress**
   - Commit frequently with clear messages (see [Git Workflow](#31-git-workflow))
   - Keep changes focused and reviewable
   - Run validation scripts often
   - Document as you go

2. **Testing**
   - Write tests before implementation
   - Maintain coverage requirements per component:
     - graph-core: 95% coverage
     - graph-service: 90% coverage
     - graph-api: 90% coverage
     - graph-builder: 85% coverage (excluding LLM components)
   - Include edge cases
   - Add integration tests for cross-package changes

3. **Documentation**
   - Update docs with code changes
   - Include examples in docstrings (Google style)
   - Document configuration changes
   - Add architecture decision records (ADRs) for significant changes

#### 3.6.2 Refactoring Best Practices
1. **Preparation**
   - Create detailed refactoring plan
   - Get team buy-in for large changes
   - Set clear success criteria
   - Plan for backward compatibility

2. **Execution**
   - Make atomic, reversible changes
   - Maintain test coverage requirements
   - Update documentation inline
   - Keep PR size manageable

3. **Review**
   - Run full validation suite
   - Check performance impact
   - Update affected documentation
   - Provide migration guides

### 3.7 Common Pitfalls to Avoid

#### 3.7.1 Implementation Pitfalls
- Skipping validation script review
- Insufficient test coverage (below component-specific requirements)
- Missing documentation updates
- Incomplete dependency analysis
- Not activating virtual environment before running commands

#### 3.7.2 Refactoring Pitfalls
- Breaking backward compatibility
- Large, monolithic changes
- Insufficient testing
- Poor communication of changes
- Inconsistent code style (not using ruff)

## 4. Performance Rules

### 4.1 Graph Operations
- **Single-User Performance Targets**:
  - Query Response Time: < 50ms for simple queries, < 200ms for complex queries
  - Batch Operation Throughput: > 1000 operations/second for local operations
  - Memory Usage: < 512MB per active graph context
  - Local Storage: Efficient file system usage for project data
  - Cache Management: Local caching for frequently accessed data

### 4.2 API Performance
- **Response Time**:
  - Simple Operations: < 100ms
  - Complex Queries: < 500ms
  - Bulk Operations: < 1s for up to 1000 items
- **Payload Size**:
  - Regular Responses: < 1MB
  - Bulk Operations: < 5MB
  - File Uploads: < 50MB
- **Caching Strategy**:
  - In-Memory Cache: Frequently accessed entities and relations
  - File System Cache: Query results and computed data
  - Cache Invalidation: Clear rules for data freshness
- **Resource Management**:
  - Memory Limits: Clear thresholds for operation size
  - Storage Quotas: Project-based storage limits
  - Background Tasks: Async processing for heavy operations

## 5. Security Rules

### 5.1 Authentication & Authorization
Note: Current implementation focuses on single-user scenarios. Authentication and authorization will be implemented in future versions.

#### Current Implementation
- **File System Security**:
  - Project-level isolation
  - File permissions for data protection
  - Local configuration security
- **API Access**:
  - Local-only API access by default
  - Basic API key for external tool integration
  - Rate limiting per API key

#### Future Implementation
- **Multi-User Authentication**:
  - JWT implementation
  - Token management
  - Session handling
- **Authorization**:
  - RBAC implementation
  - Permission granularity
  - Access control lists
- **Security Features**:
  - Audit logging
  - Token rotation
  - Rate limiting per user

### 5.2 Data Security
- **Input Validation**: Validate all input data
- **Output Sanitization**: Sanitize all output data
- **Encryption**: Use encryption for sensitive data
- **Audit Logging**: Log all sensitive operations
- **Data Retention**: Define data retention policies

## 6. Monitoring Rules

### 6.1 Logging
- **Log Levels**: Use appropriate log levels (DEBUG, INFO, WARNING, ERROR)
- **Structured Logging**: Use structured logging format
```python
{
    "timestamp": "ISO8601",
    "level": "INFO|WARNING|ERROR",
    "service": "graph-core|graph-service|graph-api",
    "operation": "operation_name",
    "tenant_id": "tenant_id",
    "graph_id": "graph_id",
    "duration_ms": 123,
    "status": "success|error",
    "error": {"code": "ERROR_CODE", "message": "error_message"}
}
```
- **Log Rotation**: Implement log rotation policies
- **Sensitive Data**: Never log sensitive data
- **Context Information**: Include relevant context in logs

### 6.2 Metrics
- **Performance Metrics**: Track response times, error rates
- **Resource Metrics**: Monitor memory, CPU usage
- **Business Metrics**: Track user actions, graph statistics
- **Alerting**: Define clear alerting thresholds
- **Dashboard**: Maintain operational dashboards

## 7. Dependency Management

### 7.1 Multi-Package Strategy
- Use separate `pyproject.toml` for each package
- Root `pyproject.toml` for development dependencies only
- Version pinning for all dependencies
- Example package configuration:
  ```toml
  # packages/graph-core/pyproject.toml
  [tool.poetry]
  name = "graph-core"
  version = "0.1.0"

  [tool.poetry.dependencies]
  python = "^3.10"
  pydantic = "2.5.2"
  ```

### 7.2 Inter-Package Dependencies
- Explicit version pinning for internal dependencies
- Use local path references during development
- Example:
  ```toml
  [tool.poetry.dependencies]
  graph-core = { path = "../graph-core", develop = true }
  ```

## 8. LLM Integration Rules

### 8.1 GraphBuilder Integration
- Use async processing for LLM operations
- Implement retry mechanisms for API calls
- Cache embeddings and results
- Example:
  ```python
  async def process_document(
      document: Document,
      retry_count: int = 3
  ) -> ProcessingResult:
      """Process document with LLM integration."""
      for attempt in range(retry_count):
          try:
              entities = await extract_entities(document)
              relations = await infer_relations(entities)
              return ProcessingResult(entities, relations)
          except LLMError as e:
              if attempt == retry_count - 1:
                  raise
              await asyncio.sleep(2 ** attempt)
  ```

### 8.2 MCP Tool Definitions
- Define clear tool boundaries
- Implement proper error handling
- Cache tool results where appropriate

## 9. Error Handling

### 9.1 Exception Hierarchy
- Implement custom exception classes for each package
- Use descriptive error messages
- Include context in exceptions
- Example:
  ```python
  class GraphError(Exception):
      """Base exception for graph operations."""
      def __init__(self, message: str, context: Optional[Dict[str, Any]] = None):
          self.message = message
          self.context = context or {}
          super().__init__(self.message)

  class ValidationError(GraphError):
      """Raised when validation fails."""
      def __init__(self, message: str, validation_errors: List[str], context: Optional[Dict[str, Any]] = None):
          self.validation_errors = validation_errors
          super().__init__(message, context)

  class BackendError(GraphError):
      """Raised when backend operations fail."""
      def __init__(self, message: str, operation: str, status_code: Optional[int] = None, context: Optional[Dict[str, Any]] = None):
          self.operation = operation
          self.status_code = status_code
          super().__init__(message, context)

  class TransactionError(GraphError):
      """Raised when transaction operations fail."""
      def __init__(self, message: str, transaction_id: str, context: Optional[Dict[str, Any]] = None):
          self.transaction_id = transaction_id
          super().__init__(message, context)

  class ConcurrencyError(GraphError):
      """Raised when concurrent operations conflict."""
      def __init__(self, message: str, resource_id: str, context: Optional[Dict[str, Any]] = None):
          self.resource_id = resource_id
          super().__init__(message, context)
  ```

### 9.2 Error Handling Strategies
- **Validation Errors**:
  - Validate input data before processing
  - Return detailed validation errors
  - Log validation failures
  - Example:
    ```python
    async def create_entity(data: Dict[str, Any]) -> Entity:
        try:
            entity = Entity.validate(data)
        except ValidationError as e:
            logger.warning("Entity validation failed", extra={
                "errors": e.validation_errors,
                "data": data
            })
            raise
        return await store_entity(entity)
    ```

- **Backend Errors**:
  - Implement retry mechanisms
  - Use circuit breakers for external services
  - Log backend failures
  - Example:
    ```python
    async def query_backend(query: Query) -> Result:
        async with CircuitBreaker(failure_threshold=3):
            try:
                return await execute_query(query)
            except BackendError as e:
                logger.error("Backend query failed", extra={
                    "operation": e.operation,
                    "status_code": e.status_code,
                    "query": query.dict()
                })
                raise
    ```

- **Transaction Errors**:
  - Implement proper rollback mechanisms
  - Log transaction failures
  - Maintain transaction state
  - Example:
    ```python
    async def execute_transaction(tx: Transaction) -> Result:
        try:
            result = await process_transaction(tx)
            await commit_transaction(tx)
            return result
        except TransactionError as e:
            logger.error("Transaction failed", extra={
                "transaction_id": e.transaction_id,
                "state": tx.state
            })
            await rollback_transaction(tx)
            raise
    ```

### 9.3 Error Recovery
- **Automatic Recovery**:
  - Implement retry mechanisms with exponential backoff
  - Maintain operation logs for rollback
  - Use circuit breakers for failing services
  - Example:
    ```python
    async def retry_with_backoff(operation: Callable, max_retries: int = 3) -> Any:
        for attempt in range(max_retries):
            try:
                return await operation()
            except RecoverableError as e:
                if attempt == max_retries - 1:
                    raise
                wait_time = 2 ** attempt
                logger.warning(f"Operation failed, retrying in {wait_time}s", extra={
                    "attempt": attempt + 1,
                    "max_retries": max_retries,
                    "error": str(e)
                })
                await asyncio.sleep(wait_time)
    ```

- **Manual Recovery**:
  - Document recovery procedures
  - Provide diagnostic tools
  - Include error codes and solutions
  - Example:
    ```python
    class RecoveryTool:
        async def diagnose_error(self, error_code: str) -> Dict[str, Any]:
            """Get diagnostic information for an error."""
            return {
                "error_code": error_code,
                "description": ERROR_DESCRIPTIONS[error_code],
                "possible_causes": ERROR_CAUSES[error_code],
                "recovery_steps": RECOVERY_STEPS[error_code]
            }

        async def attempt_recovery(self, error_code: str) -> bool:
            """Attempt to recover from a known error."""
            recovery_plan = RECOVERY_PLANS[error_code]
            try:
                await self.execute_recovery_plan(recovery_plan)
                return True
            except Exception as e:
                logger.error("Recovery failed", extra={
                    "error_code": error_code,
                    "recovery_plan": recovery_plan,
                    "error": str(e)
                })
                return False
    ```

## Examples

### Task Implementation Example

```bash
# 1. Activate virtual environment
source .venv/bin/activate

# 2. Review validation requirements
./tools/dev-scripts/task13_validation.sh
❌ Missing required file: src/mcp/routes.py

# 3. Create necessary files
cd knowledge/packages/graph-api
mkdir -p src/mcp
touch src/mcp/routes.py

# 4. Implement with tests
poetry run pytest tests/mcp/test_routes.py --cov=src/mcp --cov-report=term-missing

# 5. Run validation until passing
./tools/dev-scripts/task13_validation.sh
✅ MCP Integration implementation validated
```

### Component Refactoring Example

```bash
# 1. Activate virtual environment
source .venv/bin/activate

# 2. Analyze impact
cd knowledge/packages/graph-core
grep -r "OldComponent" .

# 3. Create refactor branch
git checkout -b refactor/modernize-old-component

# 4. Run affected validations
./tools/dev-scripts/task06_validation.sh
./tools/dev-scripts/task07_validation.sh

# 5. Make changes incrementally with tests
poetry run pytest tests/components/test_old_component.py --cov=src --cov-report=term-missing

# 6. Update dependent packages
cd ../graph-service
poetry run pytest tests/integration/test_old_component_integration.py

# 7. Verify all validations pass
cd ../../..
./tools/dev-scripts/task06_validation.sh
./tools/dev-scripts/task07_validation.sh

# 8. Run full test suite
./tools/dev-scripts/run-all-tests.sh
```

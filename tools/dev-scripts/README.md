# Development Scripts

This directory contains validation scripts for various implementation tasks. Each script performs comprehensive validation of specific components and configurations.

## Prerequisites

- Python 3.10+
- Virtual environment activated
- Docker and Docker Compose installed
- kubectl configured with appropriate cluster access
- GitHub CLI (gh) installed and authenticated
- Prometheus tools (promtool) installed
- yq installed (for YAML processing)

## Common Setup for All Scripts

Before running any validation script:

```bash
# 1. Ensure you're in the project root
cd $(git rev-parse --show-toplevel)

# 2. Make all scripts executable
chmod +x tools/dev-scripts/*.sh

# 3. Activate virtual environment
source .venv/bin/activate
```

## Available Scripts by Category

### Project Setup and Structure (Tasks 1-5)
Basic setup validation scripts that check project structure, dependencies, and development environment.

```bash
# Task 1: Project Structure and Dev Environment
./tools/dev-scripts/task1_validation.sh

# Task 2: Package Dependencies
./tools/dev-scripts/task2_validation.sh

# Task 3: Development Tools
./tools/dev-scripts/task3_validation.sh

# Task 4: Testing Framework
./tools/dev-scripts/task4_validation.sh

# Task 5: Documentation Structure
./tools/dev-scripts/task5_validation.sh
```

Validates:
- Project directory structure
- Package configurations
- Development tools installation
- Testing framework setup
- Documentation organization

### Core Implementation (Tasks 6-12)
Scripts that validate core functionality implementation.

```bash
# Task 6: Graph Context Implementation
./tools/dev-scripts/task6_validation.sh

# Task 7: Backend Connectors
./tools/dev-scripts/task7_validation.sh

# Task 8: Type System
./tools/dev-scripts/task8_validation.sh

# Task 9: Graph Manager
./tools/dev-scripts/task9_validation.sh

# Task 10: Schema API
./tools/dev-scripts/task10_validation.sh

# Task 11: Query Service
./tools/dev-scripts/task11_validation.sh

# Task 12: Entity and Relation Services
./tools/dev-scripts/task12_validation.sh
```

Validates:
- Core graph operations
- Database backend connections
- Type system implementation
- Service layer components
- API implementations
- Query functionality

### Integration and API (Tasks 13-17)
Scripts that validate API implementations and integrations.

```bash
# Task 13: MCP Integration
./tools/dev-scripts/task13_validation.sh

# Task 14: REST API Implementation
./tools/dev-scripts/task14_validation.sh

# Task 15: GraphQL API Implementation
./tools/dev-scripts/task15_validation.sh

# Task 16: Search API Implementation
./tools/dev-scripts/task16_validation.sh

# Task 17: Semantic API Implementation
./tools/dev-scripts/task17_validation.sh
```

Validates:
- FastAPI_MCP integration
- REST endpoints
- GraphQL implementation
- Search functionality
- Semantic descriptions

### UI and Frontend (Tasks 18-21)
Scripts that validate UI components and frontend functionality.

```bash
# Task 18: Graph Explorer UI
./tools/dev-scripts/task18_validation.sh

# Task 19: Schema Editor UI
./tools/dev-scripts/task19_validation.sh

# Task 20: Query Builder UI
./tools/dev-scripts/task20_validation.sh

# Task 21: Frontend Integration
./tools/dev-scripts/task21_validation.sh
```

Validates:
- UI components
- Frontend functionality
- User interactions
- Integration with backend APIs

### Deployment and Infrastructure (Tasks 22-23)
Scripts that validate deployment configurations and infrastructure setup.

```bash
# Task 22: CI/CD Pipeline
./tools/dev-scripts/task22_validation.sh

# Task 23: Production Deployment
./tools/dev-scripts/task23_validation.sh
```

These scripts require additional tools and configurations:
- GitHub Actions workflows
- Docker and Kubernetes setup
- Monitoring tools (Prometheus, Grafana)
- SSL/TLS certificates
- Backup configurations

## Common Issues and Troubleshooting

### Permission Denied
If you encounter permission denied errors:
```bash
# Fix permissions for all scripts
chmod +x tools/dev-scripts/*.sh
```

### Virtual Environment Not Found
Ensure you're in the project root and the virtual environment is activated:
```bash
# From project root
source .venv/bin/activate
```

### kubectl Not Configured
If kubectl commands fail:
```bash
# Check kubectl configuration
kubectl config current-context

# Ensure you're using the correct context
kubectl config use-context <your-context>
```

### GitHub CLI Authentication
If GitHub CLI commands fail:
```bash
# Authenticate GitHub CLI
gh auth login
```

## Exit Codes

- 0: All validations passed
- 1: One or more validations failed

## Adding New Scripts

When adding new validation scripts:
1. Use the existing scripts as templates
2. Follow the established pattern:
   - Set -e for immediate exit on error
   - Change to project root
   - Activate virtual environment
   - Group related checks into functions
   - Use clear error messages with emoji indicators
3. Update this README with:
   - Script description
   - Usage instructions
   - Specific prerequisites (if any)
   - What is being validated
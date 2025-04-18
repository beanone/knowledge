#!/bin/bash
# tools/dev-scripts/task22_validation.sh
# Validates CI/CD Pipeline implementation

set -e

# Ensure we're in the project root
cd "$(git rev-parse --show-toplevel)"

source .venv/bin/activate

# Validate GitHub Actions workflows
function validate_github_workflows() {
  # Check required workflow files
  required_workflows=(
    ".github/workflows/ci.yml"
    ".github/workflows/cd.yml"
    ".github/workflows/tests.yml"
    ".github/workflows/lint.yml"
    ".github/workflows/docs.yml"
    ".github/workflows/security.yml"
  )

  for workflow in "${required_workflows[@]}"; do
    if [ ! -f "$workflow" ]; then
      echo "❌ Missing workflow file: $workflow"
      exit 1
    fi
  done

  # Validate workflow syntax
  for workflow in "${required_workflows[@]}"; do
    if ! gh workflow view "$workflow" &>/dev/null; then
      echo "❌ Invalid workflow syntax in: $workflow"
      exit 1
    fi
  done
}

# Validate automated testing pipeline
function validate_testing_pipeline() {
  # Check test workflow configuration
  if ! yq eval '.jobs.test.strategy.matrix.python-version' .github/workflows/tests.yml | grep -q "3.10"; then
    echo "❌ Python 3.10 not included in test matrix"
    exit 1
  fi

  # Verify test coverage reporting
  if ! yq eval '.jobs.test.steps[] | select(.name == "Upload coverage")' .github/workflows/tests.yml &>/dev/null; then
    echo "❌ Missing coverage upload step in test workflow"
    exit 1
  fi

  # Check parallel test execution
  if ! yq eval '.jobs.test.strategy.matrix.package[]' .github/workflows/tests.yml | grep -q "graph-core\|graph-api\|graph-ui"; then
    echo "❌ Missing parallel package testing configuration"
    exit 1
  fi
}

# Validate deployment workflows
function validate_deployment_workflows() {
  # Check deployment environments
  required_envs=(
    "staging"
    "production"
  )

  for env in "${required_envs[@]}"; do
    if ! gh environment view "$env" &>/dev/null; then
      echo "❌ Missing GitHub environment: $env"
      exit 1
    fi
  done

  # Check deployment workflow configuration
  if ! yq eval '.on.push.branches[]' .github/workflows/cd.yml | grep -q "main\|develop"; then
    echo "❌ Missing branch triggers in deployment workflow"
    exit 1
  fi

  # Verify deployment approvals
  if ! yq eval '.jobs.deploy.environment.name' .github/workflows/cd.yml | grep -q "production"; then
    echo "❌ Missing production environment protection"
    exit 1
  fi
}

# Validate security scanning
function validate_security_scanning() {
  # Check security workflow components
  required_scans=(
    "codeql-analysis"
    "dependency-review"
    "secret-scanning"
    "container-scanning"
  )

  for scan in "${required_scans[@]}"; do
    if ! grep -r "$scan" .github/workflows/security.yml &>/dev/null; then
      echo "❌ Missing security scan: $scan"
      exit 1
    fi
  done

  # Verify security policy
  if [ ! -f "SECURITY.md" ]; then
    echo "❌ Missing security policy file"
    exit 1
  fi
}

# Validate artifact management
function validate_artifact_management() {
  # Check artifact configuration
  if ! yq eval '.jobs.build.steps[] | select(.name == "Upload artifact")' .github/workflows/ci.yml &>/dev/null; then
    echo "❌ Missing artifact upload configuration"
    exit 1
  fi

  # Verify artifact retention
  if ! yq eval '.jobs.build.steps[] | select(.name == "Upload artifact").with.retention-days' .github/workflows/ci.yml | grep -q "[0-9]"; then
    echo "❌ Missing artifact retention configuration"
    exit 1
  fi

  # Check Docker image publishing
  if ! yq eval '.jobs.publish.steps[] | select(.uses == "docker/build-push-action")' .github/workflows/cd.yml &>/dev/null; then
    echo "❌ Missing Docker image publishing configuration"
    exit 1
  fi
}

# Run all validations
validate_github_workflows
validate_testing_pipeline
validate_deployment_workflows
validate_security_scanning
validate_artifact_management

echo "✅ CI/CD Pipeline implementation validated"
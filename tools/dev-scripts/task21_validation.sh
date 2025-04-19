#!/bin/bash
# tools/dev-scripts/task21_validation.sh
# Validates CI/CD pipeline implementation

set -e

# Ensure we're in the project root
cd "$(git rev-parse --show-toplevel)"

source .venv/bin/activate

# Validate directory structure
function validate_directory_structure() {
  # Check required CI/CD configuration files
  required_files=(
    ".github/workflows/ci.yml"
    ".github/workflows/cd.yml"
    ".github/workflows/pr-checks.yml"
    ".github/workflows/release.yml"
    "tools/ci/lint.sh"
    "tools/ci/test.sh"
    "tools/ci/build.sh"
    "tools/ci/deploy.sh"
    "tools/ci/release.sh"
    "docs/ci-cd/pipeline.md"
    "docs/ci-cd/deployment-guide.md"
    "docs/ci-cd/release-process.md"
  )

  for file in "${required_files[@]}"; do
    if [ ! -f "$file" ]; then
      echo "❌ Missing required file: $file"
      echo "Please ensure all CI/CD configuration files are present"
      exit 1
    fi
  done
}

# Validate GitHub Actions workflows
function validate_workflows() {
  # Check CI workflow
  if ! yq eval '.jobs.lint' .github/workflows/ci.yml > /dev/null 2>&1; then
    echo "❌ Missing lint job in CI workflow"
    echo "Please ensure CI workflow includes linting"
    exit 1
  fi

  if ! yq eval '.jobs.test' .github/workflows/ci.yml > /dev/null 2>&1; then
    echo "❌ Missing test job in CI workflow"
    echo "Please ensure CI workflow includes testing"
    exit 1
  fi

  if ! yq eval '.jobs.build' .github/workflows/ci.yml > /dev/null 2>&1; then
    echo "❌ Missing build job in CI workflow"
    echo "Please ensure CI workflow includes build step"
    exit 1
  fi

  # Check CD workflow
  if ! yq eval '.jobs.deploy' .github/workflows/cd.yml > /dev/null 2>&1; then
    echo "❌ Missing deploy job in CD workflow"
    echo "Please ensure CD workflow includes deployment"
    exit 1
  fi

  # Check PR workflow
  if ! yq eval '.jobs.pr-validation' .github/workflows/pr-checks.yml > /dev/null 2>&1; then
    echo "❌ Missing PR validation job"
    echo "Please ensure PR workflow includes validation checks"
    exit 1
  fi

  # Check release workflow
  if ! yq eval '.jobs.release' .github/workflows/release.yml > /dev/null 2>&1; then
    echo "❌ Missing release job"
    echo "Please ensure release workflow is properly configured"
    exit 1
  fi
}

# Validate CI scripts
function validate_ci_scripts() {
  # Check lint script
  if ! bash -n tools/ci/lint.sh; then
    echo "❌ Syntax error in lint script"
    echo "Please fix syntax errors in lint.sh"
    exit 1
  fi

  # Check test script
  if ! bash -n tools/ci/test.sh; then
    echo "❌ Syntax error in test script"
    echo "Please fix syntax errors in test.sh"
    exit 1
  fi

  # Check build script
  if ! bash -n tools/ci/build.sh; then
    echo "❌ Syntax error in build script"
    echo "Please fix syntax errors in build.sh"
    exit 1
  fi

  # Check deploy script
  if ! bash -n tools/ci/deploy.sh; then
    echo "❌ Syntax error in deploy script"
    echo "Please fix syntax errors in deploy.sh"
    exit 1
  fi

  # Check release script
  if ! bash -n tools/ci/release.sh; then
    echo "❌ Syntax error in release script"
    echo "Please fix syntax errors in release.sh"
    exit 1
  fi
}

# Validate documentation
function validate_documentation() {
  # Check pipeline documentation
  if ! grep -q "Pipeline Stages" docs/ci-cd/pipeline.md; then
    echo "❌ Missing pipeline stages documentation"
    echo "Please ensure pipeline documentation includes stage descriptions"
    exit 1
  fi

  # Check deployment guide
  if ! grep -q "Deployment Steps" docs/ci-cd/deployment-guide.md; then
    echo "❌ Missing deployment steps documentation"
    echo "Please ensure deployment guide includes step-by-step instructions"
    exit 1
  fi

  # Check release process
  if ! grep -q "Release Checklist" docs/ci-cd/release-process.md; then
    echo "❌ Missing release checklist"
    echo "Please ensure release process documentation includes checklist"
    exit 1
  fi
}

# Validate environment configuration
function validate_environment_config() {
  # Check required environment variables in workflows
  required_env_vars=(
    "DOCKER_USERNAME"
    "DOCKER_PASSWORD"
    "AWS_ACCESS_KEY_ID"
    "AWS_SECRET_ACCESS_KEY"
    "DEPLOY_SSH_KEY"
  )

  for var in "${required_env_vars[@]}"; do
    if ! grep -q "$var" .github/workflows/*.yml; then
      echo "❌ Missing environment variable: $var"
      echo "Please ensure all required environment variables are configured"
      exit 1
    fi
  done

  # Check secrets configuration
  if ! grep -q "secrets:" .github/workflows/*.yml; then
    echo "❌ Missing secrets configuration"
    echo "Please ensure GitHub secrets are properly configured"
    exit 1
  fi
}

# Run all validations
echo "Validating directory structure..."
validate_directory_structure

echo "Validating GitHub Actions workflows..."
validate_workflows

echo "Validating CI scripts..."
validate_ci_scripts

echo "Validating documentation..."
validate_documentation

echo "Validating environment configuration..."
validate_environment_config

echo "✅ CI/CD pipeline implementation validated successfully!"
#!/bin/bash
# tools/dev-scripts/task23_validation.sh
# Validates Production Deployment implementation

set -e

# Ensure we're in the project root
cd "$(git rev-parse --show-toplevel)"

source .venv/bin/activate

# Validate Docker configuration
function validate_docker_configuration() {
  # Check required Docker files
  required_files=(
    "docker/Dockerfile.api"
    "docker/Dockerfile.ui"
    "docker/Dockerfile.core"
    "docker-compose.yml"
    "docker-compose.prod.yml"
    ".dockerignore"
  )

  for file in "${required_files[@]}"; do
    if [ ! -f "$file" ]; then
      echo "❌ Missing Docker file: $file"
      exit 1
    fi
  done

  # Validate Docker Compose configuration
  if ! docker-compose -f docker-compose.prod.yml config &>/dev/null; then
    echo "❌ Invalid Docker Compose configuration"
    exit 1
  fi

  # Check multi-stage builds
  for dockerfile in docker/Dockerfile.*; do
    if ! grep -q "FROM.*as.*builder" "$dockerfile"; then
      echo "❌ Missing multi-stage build in: $dockerfile"
      exit 1
    fi
  done
}

# Validate Kubernetes manifests
function validate_kubernetes_manifests() {
  # Check required K8s manifests
  required_manifests=(
    "k8s/api-deployment.yaml"
    "k8s/ui-deployment.yaml"
    "k8s/core-deployment.yaml"
    "k8s/ingress.yaml"
    "k8s/service.yaml"
    "k8s/configmap.yaml"
    "k8s/secrets.yaml"
    "k8s/hpa.yaml"
  )

  for manifest in "${required_manifests[@]}"; do
    if [ ! -f "$manifest" ]; then
      echo "❌ Missing Kubernetes manifest: $manifest"
      exit 1
    fi
  done

  # Validate manifest syntax
  for manifest in "${required_manifests[@]}"; do
    if ! kubectl apply --dry-run=client -f "$manifest" &>/dev/null; then
      echo "❌ Invalid Kubernetes manifest: $manifest"
      exit 1
    fi
  done
}

# Validate monitoring setup
function validate_monitoring_setup() {
  # Check monitoring configuration
  required_monitoring=(
    "monitoring/prometheus.yml"
    "monitoring/grafana-dashboards.json"
    "monitoring/alertmanager.yml"
    "monitoring/rules.yml"
  )

  for config in "${required_monitoring[@]}"; do
    if [ ! -f "$config" ]; then
      echo "❌ Missing monitoring configuration: $config"
      exit 1
    fi
  done

  # Validate Prometheus configuration
  if ! promtool check config monitoring/prometheus.yml &>/dev/null; then
    echo "❌ Invalid Prometheus configuration"
    exit 1
  fi

  # Check alert rules
  if ! promtool check rules monitoring/rules.yml &>/dev/null; then
    echo "❌ Invalid alert rules configuration"
    exit 1
  fi
}

# Validate backup configuration
function validate_backup_configuration() {
  # Check backup scripts
  required_scripts=(
    "scripts/backup/database-backup.sh"
    "scripts/backup/file-backup.sh"
    "scripts/backup/restore.sh"
  )

  for script in "${required_scripts[@]}"; do
    if [ ! -f "$script" ]; then
      echo "❌ Missing backup script: $script"
      exit 1
    fi
  done

  # Check backup schedule
  if ! grep -q "backup" k8s/cronjob.yaml &>/dev/null; then
    echo "❌ Missing backup schedule configuration"
    exit 1
  fi

  # Verify backup retention policy
  if ! grep -q "retention" scripts/backup/config.yml &>/dev/null; then
    echo "❌ Missing backup retention policy"
    exit 1
  fi
}

# Validate scaling configuration
function validate_scaling_configuration() {
  # Check autoscaling configuration
  if ! grep -q "maxReplicas" k8s/hpa.yaml &>/dev/null; then
    echo "❌ Missing horizontal pod autoscaling configuration"
    exit 1
  fi

  # Check resource limits
  for manifest in k8s/*deployment.yaml; do
    if ! grep -q "resources:" "$manifest" || ! grep -q "limits:" "$manifest"; then
      echo "❌ Missing resource limits in: $manifest"
      exit 1
    fi
  done

  # Verify node affinity rules
  if ! grep -q "nodeAffinity" k8s/*deployment.yaml &>/dev/null; then
    echo "❌ Missing node affinity rules"
    exit 1
  fi
}

# Validate SSL/TLS configuration
function validate_ssl_configuration() {
  # Check SSL certificate configuration
  if ! grep -q "tls:" k8s/ingress.yaml &>/dev/null; then
    echo "❌ Missing SSL/TLS configuration in ingress"
    exit 1
  fi

  # Check cert-manager configuration
  if [ ! -f "k8s/certificate.yaml" ]; then
    echo "❌ Missing cert-manager configuration"
    exit 1
  fi

  # Verify HTTPS redirect
  if ! grep -q "nginx.ingress.kubernetes.io/ssl-redirect: \"true\"" k8s/ingress.yaml &>/dev/null; then
    echo "❌ Missing HTTPS redirect configuration"
    exit 1
  fi
}

# Run all validations
validate_docker_configuration
validate_kubernetes_manifests
validate_monitoring_setup
validate_backup_configuration
validate_scaling_configuration
validate_ssl_configuration

echo "✅ Production Deployment implementation validated"
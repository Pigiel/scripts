#!/bin/sh
#
# This script can be run using curl:
#  sh -c "$(curl -fsSL https://raw.githubusercontent.com/Pigiel/scripts/main/trivy-operator/crds.sh)" "" ${VERSION}
#
# Script to automate the installation of the CRDs for the trivy-operator
# More information on the trivy-operator can be found at:
#   https://artifacthub.io/packages/helm/trivy-operator/trivy-operator
#

# Check if CRD version is provided
if [ -z "$1" ]; then
  echo "CRD version is required as the first argument"
  echo "Example usage:"
  echo "  sh -c \"\$(curl -fsSL https://raw.githubusercontent.com/Pigiel/scripts/main/trivy-operator/crds.sh)\" \"\" <version>"
  exit 1
fi

# Trivy Operator CRD Version
VERSION="$1"

# Install the CRDs for the trivy-operator in provided version
# The CRDs overview with current versions can be found at:
#   https://aquasecurity.github.io/trivy-operator/latest/docs/crds/
#
echo "Installing CRDs for Trivy Operator v${VERSION}"
kubectl apply --server-side -f https://raw.githubusercontent.com/aquasecurity/trivy-operator/v${VERSION}/deploy/helm/crds/aquasecurity.github.io_vulnerabilityreports.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/aquasecurity/trivy-operator/v${VERSION}/deploy/helm/crds/aquasecurity.github.io_configauditreports.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/aquasecurity/trivy-operator/v${VERSION}/deploy/helm/crds/aquasecurity.github.io_exposedsecretreports.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/aquasecurity/trivy-operator/v${VERSION}/deploy/helm/crds/aquasecurity.github.io_rbacassessmentreports.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/aquasecurity/trivy-operator/v${VERSION}/deploy/helm/crds/aquasecurity.github.io_clusterrbacassessmentreports.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/aquasecurity/trivy-operator/v${VERSION}/deploy/helm/crds/aquasecurity.github.io_clusterinfraassessmentreports.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/aquasecurity/trivy-operator/v${VERSION}/deploy/helm/crds/aquasecurity.github.io_infraassessmentreports.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/aquasecurity/trivy-operator/v${VERSION}/deploy/helm/crds/aquasecurity.github.io_sbomreports.yaml

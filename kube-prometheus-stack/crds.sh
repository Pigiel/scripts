#!/bin/sh
#
# This script can be run using curl:
#  sh -c "$(curl -fsSL https://raw.githubusercontent.com/Pigiel/scripts/main/kube-prometheus-stack/crds.sh)" "" ${VERSION}
#
# Script to automate the installation of the CRDs for the kube-prometheus-stack
# More information on the kube-prometheus-stack can be found at:
#   https://artifacthub.io/packages/helm/prometheus-community/kube-prometheus-stack
#

# Check if CRD version is provided
if [ -z "$1" ]; then
  echo "CRD version is required as the first argument"
  echo "Example usage:"
  echo "  sh -c \"\$(curl -fsSL https://raw.githubusercontent.com/Pigiel/scripts/main/kube-prometheus-stack/crds.sh)\" \"\" <version>"
  exit 1
fi

# Prometheus Operator CRD Version
VERSION="$1"

# Clean up existing CRDs
echo "Cleaning up existing CRDs"
kubectl delete crd alertmanagerconfigs.monitoring.coreos.com
kubectl delete crd alertmanagers.monitoring.coreos.com
kubectl delete crd podmonitors.monitoring.coreos.com
kubectl delete crd probes.monitoring.coreos.com
kubectl delete crd prometheusagents.monitoring.coreos.com
kubectl delete crd prometheuses.monitoring.coreos.com
kubectl delete crd prometheusrules.monitoring.coreos.com
kubectl delete crd scrapeconfigs.monitoring.coreos.com
kubectl delete crd servicemonitors.monitoring.coreos.com
kubectl delete crd thanosrulers.monitoring.coreos.com

# Install the CRDs for the Prometheus Operator in provided version
echo "Installing CRDs for Prometheus Operator v${VERSION}"
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v${VERSION}/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagerconfigs.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v${VERSION}/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagers.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v${VERSION}/example/prometheus-operator-crd/monitoring.coreos.com_podmonitors.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v${VERSION}/example/prometheus-operator-crd/monitoring.coreos.com_probes.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v${VERSION}/example/prometheus-operator-crd/monitoring.coreos.com_prometheusagents.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v${VERSION}/example/prometheus-operator-crd/monitoring.coreos.com_prometheuses.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v${VERSION}/example/prometheus-operator-crd/monitoring.coreos.com_prometheusrules.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v${VERSION}/example/prometheus-operator-crd/monitoring.coreos.com_scrapeconfigs.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v${VERSION}/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v${VERSION}/example/prometheus-operator-crd/monitoring.coreos.com_thanosrulers.yaml

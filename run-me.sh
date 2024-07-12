#!/bin/bash
set -ex

CLUSTER_NAME=${1:-"test0"}

(cd terraform && terraform init && terraform apply -var cluster_name=${CLUSTER_NAME})
aws eks update-kubeconfig \
    --name ${CLUSTER_NAME}

kubectl apply -f k8s/monitoring.yml

helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm upgrade --install metrics-server metrics-server/metrics-server \
    --version 3.12.1 \
    --namespace kube-system

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm upgrade --install prometheus prometheus-community/kube-prometheus-stack \
    --version 61.3.1 \
    --namespace monitoring

helm repo add grafana https://grafana.github.io/helm-charts
helm upgrade --install grafana grafana/grafana \
    --version 8.3.2 \
    --namespace monitoring \
    -f grafana/values.yml

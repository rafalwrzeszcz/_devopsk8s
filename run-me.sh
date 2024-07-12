#!/bin/bash
set -ex

CLUSTER_NAME=${1:-"test0"}

(cd terraform && terraform init && terraform apply -var cluster_name=${CLUSTER_NAME})
aws eks update-kubeconfig \
    --name ${CLUSTER_NAME}

kubectl apply -f k8s/monitoring.yml

# we need to use different port for metrics, because we use Fargate
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm upgrade --install metrics-server metrics-server/metrics-server \
    --version 3.12.1 \
    --namespace kube-system \
    --set containerPort=10251

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm upgrade --install prometheus prometheus-community/kube-prometheus-stack \
    --version 61.3.1 \
    --namespace monitoring

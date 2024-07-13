#!/bin/bash
set -ex

CLUSTER_NAME=${1:-"test0"}

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)

sed s/"%AWS_ACCOUNT_ID%"/"${AWS_ACCOUNT_ID}"/g k8s/app.yml.in > k8s/app.yml

(cd terraform && terraform init && terraform apply -var cluster_name=${CLUSTER_NAME})
aws eks update-kubeconfig \
    --name ${CLUSTER_NAME}

kubectl apply -f k8s/monitoring.yml

curl https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.7.2/docs/install/iam_policy.json \
    -o aws-load-balancer-controller.policy.json
aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://aws-load-balancer-controller.policy.json
eksctl create iamserviceaccount \
    --cluster=${CLUSTER_NAME} \
    --namespace=kube-system \
    --name=aws-load-balancer-controller \
    --role-name AmazonEKSLoadBalancerControllerRole \
    --attach-policy-arn=arn:aws:iam::${AWS_ACCOUNT_ID}:policy/AWSLoadBalancerControllerIAMPolicy \
    --approve

helm repo add eks https://aws.github.io/eks-charts
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
    --version 1.3.3 \
    --namespace kube-system \
    --set clusterName=${CLUSTER_NAME} \
    --set serviceAccount.create=false \
    --set serviceAccount.name=aws-load-balancer-controller

helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm install metrics-server metrics-server/metrics-server \
    --version 3.12.1 \
    --namespace kube-system

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/kube-prometheus-stack \
    --version 61.3.1 \
    --namespace monitoring

helm repo add grafana https://grafana.github.io/helm-charts
helm install grafana grafana/grafana \
    --version 8.3.2 \
    --namespace monitoring \
    -f grafana/values.yml

helm install mongodb oci://registry-1.docker.io/bitnamicharts/mongodb \
    --version 15.6.12 \
    --namespace default \
    --set auth.enabled=false

helm repo add elastic https://helm.elastic.co
helm install elasticsearch elastic/elasticsearch \
    --version 8.5.1 \
    --namespace monitoring
helm install filebeat elastic/filebeat \
    --version 8.5.1 \
    --namespace monitoring
helm install kibana elastic/kibana \
    --version 8.5.1 \
    --namespace monitoring

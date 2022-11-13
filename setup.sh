#!/bin/bash

set -eo pipefail

cat <<EOF | kind create cluster --wait 3m --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 7180
    protocol: TCP
  - containerPort: 443
    hostPort: 7143
    protocol: TCP
EOF
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s

# Build, load and start image
docker build -t simple-app:snapshot simple-image
kind load docker-image simple-app:snapshot
kubectl apply -f deployment.yaml
kubectl wait --namespace simple-app \
  --for=condition=ready pod \
  --selector=app=simple-app \
  --timeout=90s

sleep 5

curl -vvv -D - -f http://localhost:7180
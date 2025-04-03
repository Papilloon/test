#!/bin/bash
set -e

echo "Configuration de GitLab comme source pour ArgoCD..."
# Login to ArgoCD
argocd login localhost:8082 --username admin --password $(kubectl get secret -n argocd argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d) --insecure

# Get the host IP address as seen from the Kubernetes cluster
HOST_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')

echo "Using host IP for GitLab: ${HOST_IP}"

# Add GitLab repository using the host IP instead of localhost
argocd repo add https://github.com/Papilloon/test.git --insecure

# Create and sync the application
argocd app create my-app \
  --repo https://github.com/Papilloon/test.git \
  --path . \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace dev

argocd app sync my-app
echo "ArgoCD est maintenant lié à GitLab !"
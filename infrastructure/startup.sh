#!/bin/bash

set -e

# Update system and install dependencies
sudo yum update -y
sudo yum install -y wget git httpd

# Install Docker
if [ "$(uname -m)" != "aarch64" ]; then
    echo "This script is intended for ARM64 architecture only."
    exit 1
fi

if ! command -v docker &> /dev/null; then
    echo "Docker not found, installing..."
    sudo amazon-linux-extras enable docker
    sudo yum install -y docker
    sudo systemctl enable --now docker
    sudo usermod -aG docker $USER
    docker --version
else
    echo "Docker already installed."
    docker --version
fi

# Install Minikube
if ! command -v minikube &> /dev/null; then
    echo "Minikube not found, installing..."
    curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-arm64
    sudo install minikube-linux-arm64 /usr/local/bin/minikube
    rm -f minikube-linux-arm64
    sudo minikube config set driver docker
    minikube version
else
    echo "Minikube already installed."
    minikube version
fi

# Install kubectl
if ! command -v kubectl &> /dev/null; then
    echo "kubectl not found, installing..."
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/arm64/kubectl"
    sudo install kubectl /usr/local/bin/
    rm -f kubectl
else
    echo "kubectl already installed."
fi

echo "Installation complete."

# Starting Minikube
minikube start --driver=docker
echo "Minikube started."

# Setting up Project
git clone https://github.com/Selansis/kubernetes_challenge.git 
cd kubernetes_challenge
rm -rf infrastructure readme.md 
kubectl apply -f ./k8s_manifests/db
kubectl apply -f ./k8s_manifests/webapp
minikube service --url website-service
echo "Project setup complete."
echo "You can access the web application at the URL provided above."
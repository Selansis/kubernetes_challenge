#!/bin/bash
set -e

USER_NAME="ec2-user"

# Update system and install dependencies
yum update -y
yum install -y wget git httpd

# Install Docker if not present
if ! command -v docker &> /dev/null; then
    echo "Docker not found, installing..."
    yum install -y docker
    systemctl enable --now docker
    usermod -aG docker $USER_NAME
else
    echo "Docker already installed."
fi

# Install Minikube if not present
if ! command -v minikube &> /dev/null; then
    echo "Minikube not found, installing..."
    curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    install minikube-linux-amd64 /usr/local/bin/minikube
    rm -f minikube-linux-amd64
else
    echo "Minikube already installed."
fi

# Install kubectl if not present
if ! command -v kubectl &> /dev/null; then
    echo "kubectl not found, installing..."
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm -f kubectl
else
    echo "kubectl already installed."
fi

echo "Installation complete."

# --- Now run Minikube & project setup as non-root user ---

sudo -i -u $USER_NAME bash <<EOF
set -e
minikube config set driver docker
minikube start --driver=docker

# Clone and deploy project
cd ~
git clone https://github.com/Selansis/kubernetes_challenge.git
cd kubernetes_challenge
rm -rf infrastructure readme.md 
kubectl apply -f ./k8s_manifests/db
kubectl apply -f ./k8s_manifests/webapp
kubectl set image deployment/website-deployment apache=selansis/k8s_challenge:ec2
kubectl set resources deployment website-deployment \
  --containers=apache \
  --requests=memory="512Mi",cpu="0.5"
kubectl set resources deployment mariadb-deployment \
  --containers=mariadb \
  --requests=memory=256Mi,cpu=250m
kubectl wait --for=condition=available --timeout=300s deployment/website-deployment
kubectl wait --for=condition=available --timeout=300s deployment/mariadb-deployment

sudo usermod -aG docker ec2-user
newgrp docker
echo "You can access the web app at:"
minikube service --url website-service
EOF

echo "All done."

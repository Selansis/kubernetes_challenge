#!/bin/bash
set -e

USER_NAME="ec2-user"

# Update system and install dependencies
yum update -y
yum install -y wget git httpd

# Install Docker
if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    yum install -y docker
    systemctl enable --now docker
    usermod -aG docker $USER_NAME
fi

# Install Minikube
if ! command -v minikube &> /dev/null; then
    echo "Installing Minikube..."
    curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    install minikube-linux-amd64 /usr/local/bin/minikube
    rm -f minikube-linux-amd64
fi

# Install kubectl
if ! command -v kubectl &> /dev/null; then
    echo "Installing kubectl..."
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm -f kubectl
fi

# Run as ec2-user
sudo -i -u $USER_NAME bash <<'EOF'
set -e
minikube config set driver docker
minikube start --driver=docker --apiserver-ips=0.0.0.0

# Clone and deploy project
cd ~
[ ! -d kubernetes_challenge ] && git clone https://github.com/Selansis/kubernetes_challenge.git
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
EOF

# Configure iptables after Minikube is ready
MINIKUBE_IP=$(sudo -i -u $USER_NAME minikube ip)
echo "Configuring iptables for Minikube IP: $MINIKUBE_IP"
iptables -t nat -A PREROUTING -p tcp --dport 30007 -j DNAT --to-destination ${MINIKUBE_IP}:30007
iptables -A FORWARD -p tcp -d ${MINIKUBE_IP} --dport 30007 -j ACCEPT

# Make rules persistent
yum install -y iptables-services
service iptables save
systemctl enable --now iptables

echo "Setup completed successfully!"
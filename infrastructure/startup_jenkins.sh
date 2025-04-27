#!/bin/bash
set -e

USER_NAME="ec2-user"

echo "=== Aktualizacja systemu i instalacja podstawowych narzędzi ==="
yum update -y
yum install -y wget git httpd

echo "=== Instalacja Javy (Amazon Corretto 17) ==="
dnf install -y java-17-amazon-corretto

echo "=== Instalacja Dockera ==="
if ! command -v docker &> /dev/null; then
    yum install -y docker
    systemctl enable --now docker
    usermod -aG docker $USER_NAME
fi

echo "=== Instalacja Jenkinsa ==="
if ! command -v jenkins &> /dev/null; then
    wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
    rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
    yum install -y jenkins
    systemctl enable --now jenkins
fi

echo "=== Otwieranie portu 8080 dla Jenkinsa ==="
if systemctl is-active firewalld; then
    firewall-cmd --permanent --add-port=8080/tcp
    firewall-cmd --reload
else
    echo "Firewalld nieaktywny — pomijam otwieranie portu."
fi

echo "=== Instalacja kubectl (opcjonalnie) ==="
if ! command -v kubectl &> /dev/null; then
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm -f kubectl
fi

echo "=== Instalacja zakończona! ==="

# Pokaż adres IP EC2 i hasło do Jenkinsa
INSTANCE_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

echo "Hasło początkowe do Jenkinsa:"
cat /var/lib/jenkins/secrets/initialAdminPassword || true

#!/bin/bash
set -e

# Update system
dnf update -y

# Install dependencies
dnf install -y wget fontconfig

# Download Grafana RPM (ostatnia znana stabilna wersja)
wget https://dl.grafana.com/oss/release/grafana-10.4.1-1.x86_64.rpm

# Install manually
dnf install -y ./grafana-10.4.1-1.x86_64.rpm

# Enable and start Grafana
systemctl enable grafana-server
systemctl start grafana-server

echo "Grafana installed manually from RPM and started."

#!/bin/bash
#
# Setup for Control Plane (Master) servers

set -euxo pipefail


# ################################################################################
# If you need public access to API server using the servers Public IP adress, 
# change PUBLIC_IP_ACCESS to true.
PUBLIC_IP_ACCESS="false"
NODENAME=$(hostname -s)
POD_CIDR="192.168.0.0/16"

# Pull required images
sudo kubeadm config images pull

# Initialize kubeadm based on PUBLIC_IP_ACCESS
if [[ "$PUBLIC_IP_ACCESS" == "false" ]]; then
    
    MY_MASTER_PRIVATE_IP=${MASTER_PRIVATE_IP:-$(ip addr show ens5 | awk '/inet / {print $2}' | cut -d/ -f1)}
    echo "master private ip is $MY_MASTER_PRIVATE_IP"
    sudo kubeadm init --apiserver-advertise-address="$MY_MASTER_PRIVATE_IP" \
                      --apiserver-cert-extra-sans="$MY_MASTER_PRIVATE_IP" \
                      --pod-network-cidr="$POD_CIDR" \
                      --node-name "$NODENAME" \
                      --ignore-preflight-errors Swap

elif [[ "$PUBLIC_IP_ACCESS" == "true" ]]; then

    MY_MASTER_PUBLIC_IP=$(curl ifconfig.me && echo "")
    echo "master public ip is $MY_MASTER_PUBLIC_IP"
    sudo kubeadm init --control-plane-endpoint="$MY_MASTER_PUBLIC_IP" \
                      --apiserver-cert-extra-sans="$MY_MASTER_PUBLIC_IP" \
                      --pod-network-cidr="$POD_CIDR" \
                      --node-name "$NODENAME" \
                      --ignore-preflight-errors Swap

else
    echo "Error: MASTER_PUBLIC_IP has an invalid value: $PUBLIC_IP_ACCESS"
    exit 1
fi


# ################################################################################
# Configure kubeconfig
mkdir -p "$HOME"/.kube
sudo cp -i /etc/kubernetes/admin.conf "$HOME"/.kube/config
sudo chown "$(id -u)":"$(id -g)" "$HOME"/.kube/config


# ################################################################################
# Install Claico Network Plugin Network 
CALICO_VERSION="v3.26.1"
curl https://raw.githubusercontent.com/projectcalico/calico/$CALICO_VERSION/manifests/calico.yaml -O
kubectl apply -f calico.yaml
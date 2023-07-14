#!/bin/bash
#
# Setup for worker nodes join

set -euxo pipefail


# ################################################################################
# Configure kubeconfig
mkdir -p "$HOME"/.kube
sudo cp -i /etc/kubernetes/admin.conf "$HOME"/.kube/config || sudo cp -i /etc/kubernetes/kubelet.conf "$HOME"/.kube/config 
sudo chown "$(id -u)":"$(id -g)" "$HOME"/.kube/config


# ################################################################################
# then run sudo kubeadm join 
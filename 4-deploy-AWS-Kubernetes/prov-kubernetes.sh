#!/bin/bash

######### Install K8

curl -LO https://dl.k8s.io/release/$(curl -Ls https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

echo "Kubernetes Installed"
kubectl version --client

######### Install Minikube

curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
chmod +x minikube-linux-amd64
sudo mv minikube-linux-amd64 /usr/local/bin/minikube

minikube start \
  --driver=docker \
  --memory=4096 \
  --cpus=2

echo "Minikube installed"
kubectl get nodes
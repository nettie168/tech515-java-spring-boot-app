# Deploying in Kubernetes

## Install kubernetes (or use EKS)

```sh
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
```
Create as AMI

## Deploy

cd mysql
kubectl apply -f secret.yml
kubectl apply -f mysql-stateful-set.yml
kubectl apply -f mysql-pvc.yml
kubectl apply -f mysql-service.yml
kubectl apply -f library-configmap.yml
kubectl apply -f mysql-job.yml
cd ../sparta-app
kubectl apply -f sparta-deploy.yml
kubectl apply -f sparta-service.yml


#!/bin/bash
apt-get update -y
apt-get install -y curl

curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--write-kubeconfig-mode 644" sh -

sleep 10
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

kubectl -n argocd patch svc argocd-server -p '{"spec":{"type":"NodePort","ports":[{"port":443,"targetPort":"https","nodePort":30443},{"port":80,"targetPort":"http","nodePort":30080}]}}'

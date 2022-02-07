#!/bin/bash

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

aws eks --region us-east-2  update-kubeconfig --name udacity-cluster

kubectl -n monitoring delete secret additional-scrape-configs --ignore-not-found
kubectl -n monitoring create secret generic additional-scrape-configs --from-file=prometheus-additional.yaml

# Configure bearer token in blackbox values (taken from API step)
helm upgrade --install prometheus-blackbox prometheus-community/prometheus-blackbox-exporter -n monitoring -f blackbox-values.yaml

helm upgrade --install prometheus-stack prometheus-community/kube-prometheus-stack -n monitoring -f values.yml

# kubectl --namespace monitoring port-forward svc/prometheus-stack-grafana 3000:80
# k port-forward svc/prometheus-stack-kube-prom-prometheus 3001:9090 -n monitoring

k -n monitoring get secret prometheus-stack-grafana -o jsonpath='{.data.admin-user}' | base64 -d | xargs echo

k -n monitoring get secret prometheus-stack-grafana -o jsonpath='{.data.admin-password}' | base64 -d | xargs echo

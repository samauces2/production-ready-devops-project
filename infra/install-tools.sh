#!/bin/bash
set -e

echo  "======================================"
echo  " DEVOPS TOOLING INSTALLATION START"
echo  "======================================"

############################
# 1. INSTALL HELM
############################
echo -e "\033[32m[INFO]\033[0m Installing Helm..."
curl -s https://get.helm.sh/helm-v3.12.0-linux-amd64.tar.gz -o helm.tar.gz
tar -zxf helm.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/helm
rm -rf helm.tar.gz linux-amd64

############################
# 2. ADD HELM REPOS
############################
echo -e "\033[32m[INFO]\033[0m Adding Helm repositories..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

############################
# 3. NAMESPACE SETUP
############################
echo -e "\033[34m[INFO]\033[0m Creating namespaces..."
kubectl create namespace monitoring || true
kubectl create namespace argocd || true

############################
# 4. INSTALL PROMETHEUS STACK (includes Grafana)
############################
echo -e "\033[32m[INFO]\033[0m Installing kube-prometheus-stack..."
helm install kube-prometheus prometheus-community/kube-prometheus-stack \
  -n monitoring

echo -e "\033[33m[WARN]\033[0m Waiting for Prometheus stack..."
kubectl rollout status deployment/kube-prometheus-kube-prome-operator -n monitoring --timeout=5m || true

############################
# 5. GET GRAFANA PASSWORD
############################
echo -e "\033[34m[INFO]\033[0m Getting Grafana admin password..."
GRAFANA_PASSWORD=$(kubectl get secret kube-prometheus-grafana -n monitoring -o jsonpath="{.data.admin-password}" | base64 --decode)

echo -e "\033[34m[INFO]\033[0m Grafana admin password: $GRAFANA_PASSWORD"

############################
# 6. EXPOSE GRAFANA (PUBLIC IP)
############################
echo -e "\033[33m[WARN]\033[0m Exposing Grafana via LoadBalancer..."
kubectl patch svc kube-prometheus-grafana \
  -n monitoring \
  -p '{"spec":{"type":"LoadBalancer"}}'

############################
# 7. INSTALL ARGOCD
############################
echo -e "\033[32m[INFO]\033[0m Installing ArgoCD..."
helm install argocd argo/argo-cd \
  --namespace argocd \
  --set server.service.type=ClusterIP \
  --set server.insecure=true

echo -e "\033[33m[WARN]\033[0m Waiting for ArgoCD..."
kubectl rollout status deployment/argocd-server -n argocd --timeout=5m

############################
# 8. ARGOCD CONFIG
############################
echo -e "\033[34m[INFO]\033[0mConfiguring ArgoCD..."

ARGOCD_PASSWORD=$(kubectl get secret -n argocd argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d)

echo -e "\033[33m[WARN]\033[0mArgoCD admin password: $ARGOCD_PASSWORD"

############################
# 9. GITHUB ACCESS
############################
echo -e "\033[33m[WARN]\033[0mConfiguring GitHub access..."

GIT_USER=$GIT_USER
GIT_TOKEN=$GIT_TOKEN

kubectl create secret generic repo-github \
  --namespace argocd \
  --from-literal=url=https://github.com/samauces2/production-ready-devops-project \
  --from-literal=username=$GIT_USER \
  --from-literal=password=$GIT_TOKEN \
  --type=kubernetes.io/basic-auth || true

kubectl label secret repo-github \
  -n argocd argocd.argoproj.io/secret-type=repository || true

############################
# 10. CREATE APPLICATION
############################
echo -e "\033[34m[INFO]\033[0mCreating ArgoCD Application..."

kubectl apply -f - <<EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: netflix-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/samauces2/production-ready-devops-project
    targetRevision: Main
    path: infra/kubernetes
  destination:
    server: https://kubernetes.default.svc
    namespace: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
EOF

until kubectl get deployment netflix-app -n default >/dev/null 2>&1; do
  echo -e "\033[33m[INFO]\033[0m Waiting for deployment to be created..."
  sleep 5
done

echo -e "\033[33m[INFO]\033[0m waiting for deployment netlifx-app..."
kubectl rollout status deployment/netflix-app  --timeout=5m

############################
# FINAL OUTPUT
############################
GRAFANA_IP=$(kubectl get svc kube-prometheus-grafana -n monitoring \
  -o jsonpath='{.status.loadBalancer.ingress[0].ip}')


echo  ""
echo  "======================================"
echo  "DEPLOYMENT COMPLETE"
echo  "======================================"
echo  ""
echo  -e "\033[32m[INFO]\033[0mGrafana:  http://$GRAFANA_IP:80"
echo  -e "\033[32m[INFO]\033[0mUser:     admin"
echo  -e "\033[32m[INFO]\033[0mPassword: $GRAFANA_PASSWORD"
echo  ""

echo -e "\033[33m[INFO]\033[0m waiting for external IP..."

while true; do
  IP=$(kubectl get svc netflix-app -n default -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

  if [ -n "$IP" ]; then
    echo -e "\033[32m[INFO]\033[0mExternal IP ready: $IP"
    break
  fi

  echo -e "\033[33m[INFO]\033[0m Waiting for external IP..."
  sleep 10
done
NETFLIX_IP=$(kubectl get svc netflix-app -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo  ""
echo  -e "\033[32m[INFO]\033[0mNetflix-demo:  http://$NETFLIX_IP:80"
echo  ""

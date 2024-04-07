#!/bin/bash

# Check si minikube est en marche
if minikube status | grep "Running" &> /dev/null; then
    echo "minikube déjà lancé."
else
    # start minikube
    minikube start

    # attendre que minikube démarre
    until minikube status | grep "Running" &> /dev/null; do
        sleep 5
    done

    echo "minikube est prêt!"
fi

# récupère et print le répertoire actuel du script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
echo "le repértoire actuel est : "
pwd
# les chemins relatifs des fichiers YAML
REDIS_MASTER_CONFIG="$SCRIPT_DIR/Redis_DB/redis_master.yaml"
REDIS_REPLICAS_CONFIG="$SCRIPT_DIR/Redis_DB/redis_service.yaml"
NODEJS_APP_CONFIG="$SCRIPT_DIR/Nodejs/nodejs.yaml"
NODEJS_SERVICE_CONFIG="$SCRIPT_DIR/Nodejs/nodejs-service.yaml"
REACT_APP_CONFIG="$SCRIPT_DIR/Reactapp/react_deployment.yaml"
REACT_SERVICE_CONFIG="$SCRIPT_DIR/Reactapp/react_service.yaml"
PROMETHEUS_CONFIG="$SCRIPT_DIR/Monitoring/Prometheus/prometheus_deployment.yaml"
PROMETHEUS_SERVICE_CONFIG="$SCRIPT_DIR/Monitoring/Prometheus/prometheus_service.yaml"
GRAFANA_CONFIG="$SCRIPT_DIR/Monitoring/Grafana/grafana_deployment.yaml"
GRAFANA_SERVICE_CONFIG="$SCRIPT_DIR/Monitoring/Grafana/grafana_service.yaml"

# supression de tous les deploiements
kubectl delete deployments --all

# supression de tous les pods
kubectl delete pods --all

# supression de tous les services
kubectl delete services --all

# déploiement  Redis
kubectl apply -f "$REDIS_MASTER_CONFIG"
kubectl apply -f "$REDIS_REPLICAS_CONFIG"

# déploiement du serveur Node.js
kubectl apply -f "$NODEJS_APP_CONFIG"
kubectl apply -f "$NODEJS_SERVICE_CONFIG"

# déploiement du React
kubectl apply -f "$REACT_APP_CONFIG"
kubectl apply -f "$REACT_SERVICE_CONFIG"

#  check si Helm est installé
helm_installed() {
    command -v helm &> /dev/null
}

#  check si  repertoire Prometheus Helm  existe
prometheus_repo_added() {
    helm repo list | grep "prometheus-community" &> /dev/null
}

# check si Helm eest installé
if ! helm_installed; then
    # Install Helm if it's not already installed
    sudo snap install helm --classic
fi

# check si prom/helm existe
if ! prometheus_repo_added; then

    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    # update 
    helm repo update
fi

# check si Prometheus est installé
if helm list | grep "prometheus" &> /dev/null; then
    # suppression du prometheus existant
    helm uninstall prometheus
fi

# install Prometheus avec helm
helm install prometheus prometheus-community/prometheus

kubectl apply -f "$PROMETHEUS_CONFIG"
kubectl apply -f "$PROMETHEUS_SERVICE_CONFIG"
kubectl expose service prometheus-server --type=NodePort --target-port=9090 --name=prometheus-server-ext

# déploiement de Grafana
kubectl apply -f "$GRAFANA_CONFIG"
kubectl apply -f "$GRAFANA_SERVICE_CONFIG"

echo "L'infrastructure a été déployée avec succès."
echo "Ceci est la liste des service accessibles via votre navigateur : "
minikube service list 


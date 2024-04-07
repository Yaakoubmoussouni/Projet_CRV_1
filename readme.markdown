

# Projet AutoScaling et IaC



## Prérequis : {#prérequis-}

• Docker   
installation de docker :   
<https://docs.docker.com/engine/install/ubuntu/>   
• Minikube   

``` console
 curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 \
  && chmod +x minikube
```

 ajouter l\'exécutable Minikube à votre path :  


``` console
sudo mkdir -p /usr/local/bin/
sudo install minikube /usr/local/bin/
```

lancer minikube :   

``` console
minikube start
```

vérifier le statue de minikube :   

``` console
minikube status
```
:::

::: {.cell .markdown}
## Objectif
:::

::: {.cell .markdown}
Deploiement d\'une application sur Minikube avec auto-scaling et
monitoring utilisant Prometheus & Grafana.  
:::

::: {.cell .markdown}
### Redis
:::

::: {.cell .markdown}
Déployer une base de donnée Redis à partir de l\'image officielle Docker
(redis)   
 • <https://hub.docker.com/_/redis>   
 • <https://hub.docker.com/repository/docker/sofia016/bdredis/general>  
• <https://hub.docker.com/repository/docker/myaakoub/redis/general>  

``` console
 docker pull redis
```

ou

``` console
 docker pull sofia016/bdredis:latest
```

ou

``` console
 docker pull myaakoub/redis:latest
```
:::

::: {.cell .markdown}
### Node-Redis
:::

::: {.cell .markdown}
Déployer le serveur nodejs   
• <https://hub.docker.com/repository/docker/sofia016/node-js/general>  
• <https://hub.docker.com/repository/docker/myaakoub/node-server/general>  


``` console
  docker pull myaakoub/node-server:latest
```

ou  

``` console
  docker pull sofia016/node-js:latest
```
:::

::: {.cell .markdown}
Pour que le serveur fonctionne correctement vous devez ajouter ses
configurations dans son environment.  
:::

::: {.cell .raw}
```{=ipynb}
          env:
            - name: PORT
              value: '8080'
            - name: REDIS_URL
              value: redis://redis.default.svc.cluster.local:6379
            - name: REDIS_REPLICAS_URL
              value: redis://redis.default.svc.cluster.local:6379
```
:::

::: {.cell .markdown}
### Service
:::

::: {.cell .markdown}
Créer un service pour la base de données Redis et le rendre accessible à
l\'intérieur du cluster.   
Créer un service pour le serveur  Node-Redis et le rendre accessible de l\'exterieur du cluster.  
:::

::: {.cell .markdown}
### Pods
:::

::: {.cell .markdown}
Créer un déploiement pour la base de données Redis et le serveur
Node-Redis.  
Une fois qu\'un serveur fonctionne augmentez
le nombre de pods (Node-Redis à 2, et Redis entre 2 et 3).  
Et vérifier que cela fonctionne toujours. ceci se fait à l\'aide de l\'augmentation
de nombres de replicas dans les fichiers \"deployment\"
:::

::: {.cell .markdown}
### Frontend
:::

::: {.cell .markdown}
Pour tester que le serveur node-redis fonctionne correctement lancer un frontend :  
• <https://hub.docker.com/repository/docker/myaakoub/redis-react/general>  


``` console
docker pull myaakoub/redis-react:latest
```

• <https://hub.docker.com/repository/docker/sofia016/frontend/general>  


``` console
 docker pull sofia016/frontend:latest
```
:::

::: {.cell .markdown}
### Mise à l\'échelle
:::

::: {.cell .markdown}
Auto-scaling : Configurer l\'auto-scaling pour les composants de
l\'application, en particulier pour les déploiements de Redis et du
serveur Node.js.  
L\'auto-scaling permettra à notre
application de s\'adapter dynamiquement à la charge de travail, en
augmentant ou en diminuant le nombre de pods en fonction des besoins.  

Pour augmenter la capacité de la base de donnée redis.  
configurer le fichier YAML pour la mise à l\'échelle.  
:::

::: {.cell .markdown}
### Monitoring avec Prometheus/Grafana
:::

::: {.cell .markdown}
Monitoring : Mettre en place un système de surveillance utilisant
Prometheus et Grafana pour collecter et visualiser les métriques de
performance de notre application.  
Cela nous permettra de surveiller les performances, de détecter les problèmes potentiels et de
prendre des mesures préventives pour maintenir la santé de notre
système.  

Déployer Prometheus pour le monitoring  
•<https://hub.docker.com/r/prom/prometheus>   

``` console
 docker pull prom/prometheus
```

• <https://github.com/prometheus-community/helm-charts/tree/main/charts/prometheus>  
 ce depot git contient une configuration parfaite de
prometheus pour notre déploiement et qui a été automatisée via notre
makefile deploy-infra.sh  

Déployer Grafana pour le monitoring  
•<https://hub.docker.com/r/grafana/grafana>   

``` console
 docker pull grafana/grafana
```
:::

::: {.cell .markdown}
## Commandes utiles
:::

::: {.cell .markdown}
Visualiser les ressources déployées  
:::

::: {.cell .raw}
```{=ipynb}
kubectl get pods
kubectl get services
kubectl get deployments
```
:::

::: {.cell .markdown}
Récupérer les log d\'un pod  
:::

::: {.cell .raw}
```{=ipynb}
kubectl logs <pod-id>
```
:::

::: {.cell .markdown}
Utiliser un fichier yaml et l\'appliquer  
:::

::: {.cell .raw}
```{=ipynb}
kubectl delete -f file.yaml
kubectl apply -f file.yaml
```
:::

::: {.cell .markdown}
Un fichier deploy-infra.sh est mis à disposition, Ce script est une sort
de makefile, conçu pour automatiser le déploiement d\'un ensemble de
services sur un cluster Kubernetes Minikube.  
Il effectue les tâches suivantes :  

• Vérifie si Minikube est déjà en cours d\'exécution. Sinon, il démarreMinikube.  
• Récupère le répertoire actuel duscript.  
• Supprime tous les déploiements, pods et servicesexistants.  
• Déploie les services Redis, Node.js, React, Prometheus et Grafana à l\'aide de fichiers de configuration YAML.  
• Vérifie si Helm est installé. Sinon, il l\'installe.  
• Ajoute le référentiel Helm Prometheus et met à jour les référentiels Helm.  
• Vérifie si une version de Prometheus est déjà installée. Si oui, il la désinstalle.  
• Installe Prometheus à l\'aide de Helm.  
• Déploie Grafana.  
• Affiche un message indiquant que l\'infrastructure a été déployée avec succès et liste les services  
accessibles via le navigateur à l\'aide de minikube servicelist.  

Utilisez le script fourni deploy-infra.sh pour automatiser le
déploiement des services sur Minikube. Assurez-vous d\'avoir les droits
d\'exécution sur le script (chmod +x deploy-infra.sh) puis lancez-le
avec :   

``` console
./deploy-infra.sh
```

Ce script facilitera le déploiement de votre infrastructure sur
Minikube, vous permettant ainsi de vous concentrer sur le développement
de votre application.  
:::

#!/bin/bash

##################
### Apps Setup ###
##################

### Set variables

# Zookeeper
declare -A zookeeper
zookeeper["name"]="zookeeper"
zookeeper["namespace"]="kafka"
zookeeper["port"]=2181

# Kafka
declare -A kafka
kafka["name"]="kafka"
kafka["namespace"]="kafka"
kafka["port"]=9092

# Producer
declare -A producer
producer["name"]="producer"
producer["namespace"]="prod"
producer["port"]=8080

# Consumer
declare -A consumer
consumer["name"]="consumer"
consumer["namespace"]="cons"
consumer["port"]=8080

# Topic
topicName="mytopic"

### Build & Push

# Zookeeper
echo -e "\n--- ZOOKEEPER ---\n"
docker build --tag "${DOCKERHUB_NAME}/${zookeeper[name]}" ../../apps/kafka/zookeeper/.
docker push "${DOCKERHUB_NAME}/${zookeeper[name]}"
echo -e "\n------\n"

# Kafka
echo -e "\n--- KAFKA ---\n"
docker build --tag "${DOCKERHUB_NAME}/${kafka[name]}" ../../apps/kafka/kafka/.
docker push "${DOCKERHUB_NAME}/${kafka[name]}"
echo -e "\n------\n"

# Producer
echo -e "\n--- PRODUCER ---\n"
docker build --tag "${DOCKERHUB_NAME}/${producer[name]}" ../../apps/producer/.
docker push "${DOCKERHUB_NAME}/${producer[name]}"
echo -e "\n------\n"

# Consumer
echo -e "\n--- CONSUMER ---\n"
docker build --tag "${DOCKERHUB_NAME}/${consumer[name]}" ../../apps/consumer/.
docker push "${DOCKERHUB_NAME}/${consumer[name]}"
echo -e "\n------\n"

# Newrelic
echo "Deploying Newrelic ..."

kubectl apply -f https://download.newrelic.com/install/kubernetes/pixie/latest/px.dev_viziers.yaml && \
    kubectl apply -f https://download.newrelic.com/install/kubernetes/pixie/latest/olm_crd.yaml && \
    helm repo add newrelic https://helm-charts.newrelic.com && helm repo update && \
    kubectl create namespace newrelic ; helm upgrade --install newrelic-bundle newrelic/nri-bundle \
    --wait \
    --debug \
    --set global.licenseKey=$NEWRELIC_LICENSE_KEY \
    --set global.cluster=${kafka[name]} \
    --namespace=newrelic \
    --set newrelic-infrastructure.privileged=true \
    --set global.lowDataMode=true \
    --set ksm.enabled=true \
    --set kubeEvents.enabled=true \
    --set prometheus.enabled=true \
    --set logging.enabled=true \
    --set newrelic-pixie.enabled=true \
    --set newrelic-pixie.apiKey=$PIXIE_API_KEY \
    --set pixie-chart.enabled=true \
    --set pixie-chart.deployKey=$PIXIE_DEPLOY_KEY \
    --set pixie-chart.clusterName=${kafka[name]}

# Zookeeper
echo "Deploying Zookeeper ..."

helm upgrade ${zookeeper[name]} \
    --install \
    --wait \
    --debug \
    --create-namespace \
    --namespace ${zookeeper[namespace]} \
    --set dockerhubName=$DOCKERHUB_NAME \
    ../charts/zookeeper

# Kafka
echo "Deploying Kafka ..."

helm upgrade ${kafka[name]} \
    --install \
    --wait \
    --debug \
    --create-namespace \
    --namespace ${kafka[namespace]} \
    --set dockerhubName=$DOCKERHUB_NAME \
    ../charts/kafka

# Topic
echo "Checking topic [$topicName] ..."

mytopic=$(kubectl exec -n "${kafka[namespace]}" "${kafka[name]}-0" -it -- bash \
    /kafka/bin/kafka-topics.sh \
    --bootstrap-server "${kafka[name]}.${kafka[namespace]}.svc.cluster.local:${kafka[port]}" \
    --list \
    | grep $topicName)

echo " -> Mytopic: $mytopic"

if [[ $mytopic == "" ]]; then

    echo " -> Topic does not exist. Creating ..."
    while :
    do
        isTopicCreated=$(kubectl exec -n "${kafka[namespace]}" "${kafka[name]}-0" -it -- bash \
            /kafka/bin/kafka-topics.sh \
            --bootstrap-server "${kafka[name]}.${kafka[namespace]}.svc.cluster.local:${kafka[port]}" \
            --create \
            --topic $topicName \
            2> /dev/null)

        if [[ $isTopicCreated == "" ]]; then
            echo " -> Kafka pods are not fully ready yet. Waiting ..."
            sleep 2
            continue
        fi

        echo -e " -> Topic is created successfully.\n"
        break

    done
else
    echo -e " -> Topic already exists.\n"
fi

# Producer
echo "Deploying Producer  ..."

helm upgrade ${producer[name]} \
    --install \
    --wait \
    --debug \
    --create-namespace \
    --namespace ${producer[namespace]} \
    --set dockerhubName=$DOCKERHUB_NAME \
    ../charts/producer

# Consumer
echo "Deploying Consumer ..."

helm upgrade ${consumer[name]} \
    --install \
    --wait \
    --debug \
    --create-namespace \
    --namespace ${consumer[namespace]} \
    --set dockerhubName=$DOCKERHUB_NAME \
    ../charts/consumer

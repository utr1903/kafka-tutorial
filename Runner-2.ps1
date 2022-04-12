### Test Kafka server

## Build & Push

# Zookeeper Server
docker build --tag utr1903/zookeeper .\apps\kafka\zookeeper\.
docker push utr1903/zookeeper

# Kafka Server
docker build --tag utr1903/kafka .\apps\kafka\kafka\.
docker push utr1903/kafka

# Producer
docker build --tag utr1903/producer .\apps\producer\.
docker push utr1903/producer

# Consumer
docker build --tag utr1903/consumer .\apps\consumer\.
docker push utr1903/consumer

## K8s

# Namespaces
kubectl create ns kafka
kubectl create ns prod
kubectl create ns cons

# Zookeeper
Write-Host "Deploying Zookeeper ..."

kubectl apply -f .\infra\k8s\zookeeper
while ($true) {

    $zookeeper = $(kubectl get pod -n kafka -l app=zookeeper -o json | ConvertFrom-Json)
    $isReady = $zookeeper.items.status.containerStatuses[0].ready

    if ($isReady) {
        Write-Host "Pod ready!"
        break;
    }

    Write-Host "Pod not ready yet."
    Start-Sleep 2
}

# Kafka
Write-Host "Deploying Kafka ..."

kubectl apply -f .\infra\k8s\kafka
while ($true) {

    $kafka = $(kubectl get pod -n kafka -l app=kafka -o json | ConvertFrom-Json)
    $isReady = $kafka.items.status.containerStatuses[0].ready

    if ($isReady) {
        Write-Host "Pod ready!"
        break;
    }

    Write-Host "Pod not ready yet."
    Start-Sleep 2
}

# Topic
kubectl exec kafka-0 -n kafka -it -- bash `
    /kafka/bin/kafka-topics.sh `
    --bootstrap-server kafka:9092 `
    --create `
    --topic mytopic

# # Producer
# kubectl exec kafka-0-0 -n kafka -it -- bash `
#     /kafka/bin/kafka-console-producer.sh `
#     --bootstrap-server kafka-0:9092 `
#     --topic first

# # Consumer
# kubectl exec kafka-0-0 -n kafka -it -- bash `
#     /kafka/bin/kafka-console-consumer.sh `
#     --bootstrap-server kafka-0:9092 `
#     --topic first

# Producer
Write-Host "Deploying Producer  ..."

kubectl apply -f .\infra\k8s\producer
while ($true) {

    $producer = $(kubectl get pod -n prod -l app=producer -o json | ConvertFrom-Json)
    $isReady = $producer.items.status.containerStatuses[0].ready

    if ($isReady) {
        Write-Host "Pod ready!"
        break;
    }

    Write-Host "Pod not ready yet."
    Start-Sleep 2
}

# Consumer
Write-Host "Deploying Consumer ..."

kubectl apply -f .\infra\k8s\consumer
while ($true) {

    $consumer = $(kubectl get pod -n cons -l app=consumer -o json | ConvertFrom-Json)
    $isReady = $consumer.items.status.containerStatuses[0].ready

    if ($isReady) {
        Write-Host "Pod ready!"
        break;
    }

    Write-Host "Pod not ready yet."
    Start-Sleep 2
}

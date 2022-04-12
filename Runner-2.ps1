## Test Kafka server

## Zookeeper Server 0

# Build
docker build --tag utr1903/zookeeper-0 .\zookeeper-0\.

# Run
docker push utr1903/zookeeper-0

## Kafka Server 0

# Build
docker build --tag utr1903/kafka-0 .\kafka-0\.

# Run
docker push utr1903/kafka-0

## Producer

# Build
docker build --tag utr1903/producer .\apps\producer\.

# Run
docker push utr1903/producer

## K8s

# Namespaces
kubectl create ns kafka
kubectl create ns prod

# Zookeeper

kubectl apply -f .\infra\k8s\zookeeper
while ($true) {

    $zookeeper = $(kubectl get pod -n kafka -l app=zookeeper-0 -o json | ConvertFrom-Json)
    $isReady = $zookeeper.items.status.containerStatuses[0].ready

    if ($isReady) {
        Write-Host "Pod ready!"
        break;
    }

    Write-Host "Pod not ready yet."
    Start-Sleep 2
}

# Kafka

kubectl apply -f .\infra\k8s\kafka
while ($true) {

    $kafka = $(kubectl get pod -n kafka -l app=kafka-0 -o json | ConvertFrom-Json)
    $isReady = $kafka.items.status.containerStatuses[0].ready

    if ($isReady) {
        Write-Host "Pod ready!"
        break;
    }

    Write-Host "Pod not ready yet."
    Start-Sleep 2
}

## Topic

# Create
kubectl exec kafka-0-0 -n kafka -it -- bash `
    /kafka/bin/kafka-topics.sh `
    --bootstrap-server kafka-0:9092 `
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

### Kafka Tutorial

#####################
### Set variables ###
#####################

# Zookeeper
$zookeeper = @{
    name       = "zookeeper"
    namespace  = "kafka"
    clientPort = 2181
}

# Kafka
$kafka = @{
    name       = "kafka"
    namespace  = "kafka"
    clientPort = 9092
}

# Producer
$producer = @{
    name      = "producer"
    namespace = "prod"
    port      = 8080
}

# Consumer
$consumer = @{
    name       = "consumer"
    namespace  = "cons"
    clientPort = 8080
}

####################
### Build & Push ###
####################

# Zookeeper
docker build --tag "utr1903/$($zookeeper.name)" ..\..\apps\kafka\zookeeper\.
docker push "utr1903/$($zookeeper.name)"

# Kafka
docker build --tag "utr1903/$($kafka.name)" ..\..\apps\kafka\kafka\.
docker push "utr1903/$($kafka.name)"

# Producer
docker build --tag "utr1903/$($producer.name)" ..\..\apps\producer\.
docker push "utr1903/$($producer.name)"

# Consumer
docker build --tag "utr1903/$($consumer.name)" ..\..\apps\consumer\.
docker push "utr1903/$($consumer.name)"

############
### Helm ###
############

# Zookeeper
Write-Host "Deploying Zookeeper ..."

helm upgrade -f ..\charts\zookeeper
while ($true) {

    $isReady = $(kubectl get pod -n "$($zookeeper.namespace)" -l "app=$($zookeeper.name)" -o json `
        | ConvertFrom-Json).items.status.containerStatuses[0].ready

    if ($isReady) {
        Write-Host "Pod ready!"
        break;
    }

    Write-Host "Pod not ready yet ..."
    Start-Sleep 2
}

# Kafka
Write-Host "Deploying Kafka ..."

helm upgrade -f ..\charts\kafka
while ($true) {

    $isReady = $(kubectl get pod -n "$($kafka.namespace)" -l "app=$($kafka.name)" -o json `
        | ConvertFrom-Json).items.status.containerStatuses[0].ready

    if ($isReady) {
        Write-Host "Pod ready!"
        break;
    }

    Write-Host "Pod not ready yet ..."
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

helm upgrade -f ..\charts\producer
while ($true) {

    $isReady = $(kubectl get pod -n "$($producer.namespace)" -l "app=$($producer.name)" -o json `
        | ConvertFrom-Json).items.status.containerStatuses[0].ready

    if ($isReady) {
        Write-Host "Pod ready!"
        break;
    }

    Write-Host "Pod not ready yet ..."
    Start-Sleep 2
}

# Consumer
Write-Host "Deploying Consumer ..."

helm upgrade -f ..\charts\producer
while ($true) {

    $isReady = $(kubectl get pod -n "$($consumer.namespace)" -l "app=$($consumer.name)" -o json `
        | ConvertFrom-Json).items.status.containerStatuses[0].ready

    if ($isReady) {
        Write-Host "Pod ready!"
        break;
    }

    Write-Host "Pod not ready yet ..."
    Start-Sleep 2
}

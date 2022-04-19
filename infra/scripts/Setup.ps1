### Kafka Tutorial

#####################
### Set variables ###
#####################

# Zookeeper
$zookeeper = @{
    name      = "zookeeper"
    namespace = "kafka"
    port      = 2181
}

# Kafka
$kafka = @{
    name      = "kafka"
    namespace = "kafka"
    port      = 9092
}

# Producer
$producer = @{
    name      = "producer"
    namespace = "prod"
    port      = 8080
}

# Consumer
$consumer = @{
    name      = "consumer"
    namespace = "cons"
    port      = 8080
}

####################
### Build & Push ###
####################

# Zookeeper
Write-Host "`n--- ZOOKEEPER ---`n"
docker build --tag "utr1903/$($zookeeper.name)" ..\..\apps\kafka\zookeeper\.
docker push "utr1903/$($zookeeper.name)"
Write-Host "`n------`n"

# Kafka
Write-Host "`n--- KAFKA ---`n"
docker build --tag "utr1903/$($kafka.name)" ..\..\apps\kafka\kafka\.
docker push "utr1903/$($kafka.name)"
Write-Host "`n------`n"

# Producer
Write-Host "`n--- PRODUCER ---`n"
docker build --tag "utr1903/$($producer.name)" ..\..\apps\producer\.
docker push "utr1903/$($producer.name)"
Write-Host "`n------`n"

# Consumer
Write-Host "`n--- CONSUMER ---`n"
docker build --tag "utr1903/$($consumer.name)" ..\..\apps\consumer\.
docker push "utr1903/$($consumer.name)"
Write-Host "`n------`n"

############
### Helm ###
############

# Zookeeper
Write-Host "Deploying Zookeeper ..."

helm upgrade $($zookeeper.name) `
    --install `
    --create-namespace `
    --namespace $($zookeeper.namespace) `
    ..\charts\zookeeper

while ($true) {

    try {
        $isReady = $(kubectl get pod -n "$($zookeeper.namespace)" -l "app=$($zookeeper.name)" -o json `
            | ConvertFrom-Json).items.status.containerStatuses[0].ready
    }
    catch {
        Write-Host "Creating container ..."
        Start-Sleep 2
    }

    if ($isReady) {
        Write-Host "Pod ready!`n"
        break;
    }

    Write-Host "Pod not ready yet ..."
    Start-Sleep 2
}

# Kafka
Write-Host "Deploying Kafka ..."

helm upgrade $($kafka.name) `
    --install `
    --create-namespace `
    --namespace $($kafka.namespace) `
    ..\charts\kafka

while ($true) {

    try {
        $isReady = $(kubectl get pod -n "$($kafka.namespace)" -l "app=$($kafka.name)" -o json `
            | ConvertFrom-Json).items.status.containerStatuses[0].ready
    }
    catch {
        Write-Host "Creating container ..."
        Start-Sleep 2
    }

    if ($isReady) {
        Write-Host "Pod ready!`n"
        break;
    }

    Write-Host "Pod not ready yet ..."
    Start-Sleep 2
}

# Topic
Write-Host "Creating topic [mytopic] ..."

while ($true) {
    $result = $(kubectl exec -n "$($kafka.namespace)" "$($kafka.name)-0" -it -- bash `
            /kafka/bin/kafka-topics.sh `
            --bootstrap-server "$($kafka.name).$($kafka.namespace).svc.cluster.local:$($kafka.port)" `
            --create `
            --topic mytopic `
            >$null 2>&1)

    if (!$result) {
        Write-Host "Kafka pods are not fully ready yet. Waiting ..."
        Start-Sleep 2
        continue
    }

    Write-Host "Topic is created successfully.`n"
    break
}

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

helm upgrade $($producer.name) `
    --install `
    --create-namespace `
    --namespace $($producer.namespace) `
    ..\charts\producer

while ($true) {

    try {
        $isReady = $(kubectl get pod -n "$($producer.namespace)" -l "app=$($producer.name)" -o json `
            | ConvertFrom-Json).items.status.containerStatuses[0].ready   
    }
    catch {
        Write-Host "Creating container ..."
        Start-Sleep 2
    }

    if ($isReady) {
        Write-Host "Pod ready!`n"
        break;
    }

    Write-Host "Pod not ready yet ..."
    Start-Sleep 2
}

# Consumer
Write-Host "Deploying Consumer ..."

helm upgrade $($consumer.name) `
    --install `
    --create-namespace `
    --namespace $($consumer.namespace) `
    ..\charts\consumer

while ($true) {

    try {
        $isReady = $(kubectl get pod -n "$($consumer.namespace)" -l "app=$($consumer.name)" -o json `
            | ConvertFrom-Json).items.status.containerStatuses[0].ready
    }
    catch {
        Write-Host "Creating container ..."
        Start-Sleep 2
    }

    if ($isReady) {
        Write-Host "Pod ready!`n"
        break;
    }

    Write-Host "Pod not ready yet ..."
    Start-Sleep 2
}

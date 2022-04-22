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

# Newrelic
Write-Host "Deploying Newrelic ..."

kubectl apply -f https://download.newrelic.com/install/kubernetes/pixie/latest/px.dev_viziers.yaml && `
    kubectl apply -f https://download.newrelic.com/install/kubernetes/pixie/latest/olm_crd.yaml && `
    helm repo add newrelic https://helm-charts.newrelic.com && helm repo update && `
    kubectl create namespace newrelic ; helm upgrade --install newrelic-bundle newrelic/nri-bundle `
    --wait `
    --debug `
    --set global.licenseKey=$env:NEWRELIC_LICENSE_KEY `
    --set global.cluster=$kafka.name `
    --namespace=newrelic `
    --set newrelic-infrastructure.privileged=true `
    --set global.lowDataMode=true `
    --set ksm.enabled=true `
    --set kubeEvents.enabled=true `
    --set prometheus.enabled=true `
    --set logging.enabled=true `
    --set newrelic-pixie.enabled=true `
    --set newrelic-pixie.apiKey=$env:PIXIE_API_KEY `
    --set pixie-chart.enabled=true `
    --set pixie-chart.deployKey=$env:PIXIE_DEPLOY_KEY `
    --set pixie-chart.clusterName=$kafka.name

# Zookeeper
Write-Host "Deploying Zookeeper ..."

helm upgrade $($zookeeper.name) `
    --install `
    --wait `
    --debug `
    --create-namespace `
    --namespace $($zookeeper.namespace) `
    ..\charts\zookeeper

while ($true) {

    try {
        $isReady = $(kubectl get pod -n "$($zookeeper.namespace)" -l "app=$($zookeeper.name)" -o json `
            | ConvertFrom-Json).items.status.containerStatuses[0].ready
    }
    catch {
        Write-Host " -> Creating container ..."
        Start-Sleep 2
    }

    if ($isReady) {
        Write-Host " -> Pod ready!`n"
        break;
    }

    Write-Host " -> Pod not ready yet ..."
    Start-Sleep 2
}

# Kafka
Write-Host "Deploying Kafka ..."

helm upgrade $($kafka.name) `
    --install `
    --wait `
    --debug `
    --create-namespace `
    --namespace $($kafka.namespace) `
    ..\charts\kafka

while ($true) {

    try {
        $isReady = $(kubectl get pod -n "$($kafka.namespace)" -l "app=$($kafka.name)" -o json `
            | ConvertFrom-Json).items.status.containerStatuses[0].ready
    }
    catch {
        Write-Host " -> Creating container ..."
        Start-Sleep 2
    }

    if ($isReady) {
        Write-Host " -> Pod ready!`n"
        break;
    }

    Write-Host " -> Pod not ready yet ..."
    Start-Sleep 2
}

# Topic
Write-Host "Checking topic [mytopic] ..."

$mytopic = $(kubectl exec -n "$($kafka.namespace)" "$($kafka.name)-0" -it -- bash `
        /kafka/bin/kafka-topics.sh `
        --bootstrap-server "$($kafka.name).$($kafka.namespace).svc.cluster.local:$($kafka.port)" `
        --list `
    | Select-String -Pattern "mytopic")

if (!$mytopic) {

    Write-Host " -> Topic does not exist. Creating ..."
    while ($true) {

        ($isCreated = kubectl exec -n "$($kafka.namespace)" "$($kafka.name)-0" -it -- bash `
            /kafka/bin/kafka-topics.sh `
            --bootstrap-server "$($kafka.name).$($kafka.namespace).svc.cluster.local:$($kafka.port)" `
            --create `
            --topic mytopic)
        2> $null 

        if (!$isCreated) {
            Write-Host " -> Kafka pods are not fully ready yet. Waiting ..."
            Start-Sleep 2
            continue
        }

        Write-Host " -> Topic is created successfully.`n"
        break
    }

}
else {
    Write-Host " -> Topic already exists.`n"
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
    --wait `
    --debug `
    --create-namespace `
    --namespace $($producer.namespace) `
    ..\charts\producer

while ($true) {

    try {
        $isReady = $(kubectl get pod -n "$($producer.namespace)" -l "app=$($producer.name)" -o json `
            | ConvertFrom-Json).items.status.containerStatuses[0].ready   
    }
    catch {
        Write-Host " -> Creating container ..."
        Start-Sleep 2
    }

    if ($isReady) {
        Write-Host " -> Pod ready!`n"
        break;
    }

    Write-Host " -> Pod not ready yet ..."
    Start-Sleep 2
}

# Consumer
Write-Host "Deploying Consumer ..."

helm upgrade $($consumer.name) `
    --install `
    --wait `
    --debug `
    --create-namespace `
    --namespace $($consumer.namespace) `
    ..\charts\consumer

while ($true) {

    try {
        $isReady = $(kubectl get pod -n "$($consumer.namespace)" -l "app=$($consumer.name)" -o json `
            | ConvertFrom-Json).items.status.containerStatuses[0].ready
    }
    catch {
        Write-Host " -> Creating container ..."
        Start-Sleep 2
    }

    if ($isReady) {
        Write-Host " -> Pod ready!`n"
        break;
    }

    Write-Host " -> Pod not ready yet ..."
    Start-Sleep 2
}

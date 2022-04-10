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

## Topic

# Create
kubectl exec kafka-0-0 -n kafka -it -- bash `
    /kafka/bin/kafka-topics.sh `
    --bootstrap-server kafka-0:9092 `
    --create `
    --topic mytopic

# Producer
# bash kafka-console-producer.sh --bootstrap-server kafka-0:9092 --topic first

# Consumer
# bash kafka-console-consumer.sh --bootstrap-server kafka-0:9092 --topic first

## Producer

# Build
docker build --tag utr1903/producer .\apps\producer\.

# Run
docker push utr1903/producer

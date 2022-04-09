### Test Kafka server

## Network
docker network create kafka

## Zookeeper Server 0

# Build
docker build --tag zookeeper-0 .\zookeeper-0\.

# Run
docker run -d --rm --name zookeeper-0 --net kafka zookeeper-0

## Kafka Server 0

# Build
docker build --tag kafka-0 .\kafka-0\.

# Run
docker run -d --rm --name kafka-0 --net kafka kafka-0

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

## Kafka Server 1

# Build
docker build --tag kafka-1 .\kafka-1\.

# Run
docker run -d --rm --name kafka-1 --net kafka kafka-1

## Kafka Server 2

# Build
docker build --tag kafka-2 .\kafka-2\.

# Run
docker run -d --rm --name kafka-2 --net kafka kafka-2

## Topics

# Create
docker run --rm --name test --net kafka kafka-0 bash `
    /kafka/bin/kafka-topics.sh `
    --bootstrap-server kafka-0:9092 `
    --create `
    --topic first `
    --partitions 3 `
    --replication-factor 3

# Describe
docker run --rm --name test --net kafka kafka-0 bash `
    /kafka/bin/kafka-topics.sh `
    --bootstrap-server kafka-0:9092 `
    --describe `
    --topic first

# List
docker run --rm --name test --net kafka kafka-0 bash `
    /kafka/bin/kafka-topics.sh `
    --bootstrap-server kafka-0:9092 `
    --list

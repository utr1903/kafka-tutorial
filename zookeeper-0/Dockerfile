FROM openjdk:11.0.10-jre-buster

RUN apt-get update && \
    apt-get install -y curl

ENV KAFKA_VERSION 3.1.0
ENV SCALA_VERSION 2.13 

RUN  mkdir /tmp/kafka && \
    curl "https://downloads.apache.org/kafka/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz" \
    -o /tmp/kafka/kafka.tgz && \
    mkdir /kafka && cd /kafka && \
    tar -xvzf /tmp/kafka/kafka.tgz --strip 1


RUN mkdir server
COPY zookeeper.properties /server

RUN chmod +x /kafka/bin/zookeeper-server-start.sh

CMD ["/kafka/bin/zookeeper-server-start.sh", "/server/zookeeper.properties"]

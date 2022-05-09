FROM openjdk:11.0.10-jre-buster

# Update apt & get curl
RUN apt-get update && \
    apt-get install -y curl

# Set env vars
ENV KAFKA_VERSION 3.1.0
ENV SCALA_VERSION 2.13 

# Download kafka binaries
RUN  mkdir /tmp/kafka && \
    curl "https://downloads.apache.org/kafka/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz" \
    -o /tmp/kafka/kafka.tgz && \
    mkdir /kafka && cd /kafka && \
    tar -xvzf /tmp/kafka/kafka.tgz --strip 1

# Copy files
RUN mkdir runner
COPY runner.sh /runner
COPY server.properties /runner

RUN chmod +x /runner/runner.sh

# Trim CRLF to LF (if Windows)
RUN sed -i s/"\\r"/""/g /runner/runner.sh
RUN sed -i s/"\\r"/""/g /runner/server.properties

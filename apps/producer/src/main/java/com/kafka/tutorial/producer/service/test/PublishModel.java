package com.kafka.tutorial.producer.service.test;

public class PublishModel {

    private String topic;
    private int partition;
    private long timestamp;

    public void setTopic(String topic) {
        this.topic = topic;
    }

    public String getTopic() { return topic; }

    public void setPartition(int partition) { this.partition = partition; }

    public int getPartition() {
        return partition;
    }

    public void setTimestamp(long timestamp) {
        this.timestamp = timestamp;
    }

    public long getTimestamp() {
        return timestamp;
    }
}

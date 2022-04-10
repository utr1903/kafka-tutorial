package com.kafka.tutorial.producer.dtos;

public class KafkaRequestDto {

    private String topic;
    private String value;

    public void setTopic(String topic) {
        this.topic = topic;
    }

    public String getTopic() {
        return topic;
    }

    public void setValue(String value) {
        this.value = value;
    }

    public String getValue() {
        return value;
    }
}

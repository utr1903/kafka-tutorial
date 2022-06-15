package com.kafka.tutorial.producer.service.kafka;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class PublishModel {

    private String topic;
    private int partition;
    private long timestamp;
}

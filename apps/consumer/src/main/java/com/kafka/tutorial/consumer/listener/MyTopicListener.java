package com.kafka.tutorial.consumer.listener;

import com.kafka.tutorial.consumer.constant.Constants;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

@Service
public class MyTopicListener {

    private static final String TOPIC = "mytopic";

    public MyTopicListener()
    {
    }

    @KafkaListener(topics = TOPIC, groupId = Constants.GROUP_ID)
    public void listen(String message)
    {
        System.out.println(message);
    }
}

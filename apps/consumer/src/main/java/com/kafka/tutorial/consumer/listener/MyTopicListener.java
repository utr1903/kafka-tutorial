package com.kafka.tutorial.consumer.listener;

import com.kafka.tutorial.consumer.constant.Constants;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

import java.util.Arrays;

@Service
public class MyTopicListener {

    private final Logger logger = LoggerFactory.getLogger(MyTopicListener.class);

    private static final String TOPIC = "mytopic";

    public MyTopicListener()
    {
    }

    @KafkaListener(topics = TOPIC, groupId = Constants.GROUP_ID)
    public void listen(ConsumerRecord<String, String> record)
    {
        for (var header : record.headers()) {
            String value = new String(header.value());
            logger.info("Header key  : " + header.key());
            logger.info("Header value: " + value);
        }

        logger.info("Message key: " + record.key());
        logger.info("Message value: " + record.value());
    }
}
